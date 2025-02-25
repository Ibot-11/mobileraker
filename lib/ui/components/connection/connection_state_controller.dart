/*
 * Copyright (c) 2023. Patrick Schmidt.
 * All rights reserved.
 */

import 'dart:async';

import 'package:common/data/model/hive/machine.dart';
import 'package:common/exceptions/octo_everywhere_exception.dart';
import 'package:common/network/jrpc_client_provider.dart';
import 'package:common/network/json_rpc_client.dart';
import 'package:common/service/app_router.dart';
import 'package:common/service/moonraker/klippy_service.dart';
import 'package:common/service/selected_machine_service.dart';
import 'package:mobileraker/routing/app_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'connection_state_controller.g.dart';

@riverpod
class ConnectionStateController extends _$ConnectionStateController {
  @override
  Future<ClientState> build() => ref.watch(jrpcClientStateSelectedProvider.selectAsync((data) => data));

  onRetryPressed() {
    ref.read(jrpcClientSelectedProvider).openChannel();
  }

  String get clientErrorMessage {
    var jsonRpcClient = ref.read(jrpcClientSelectedProvider);
    Exception? errorReason = jsonRpcClient.errorReason;
    if (errorReason is TimeoutException) {
      return 'A timeout occurred while trying to connect to the machine! Ensure the machine can be reached from your current network...';
    } else if (errorReason is OctoEverywhereException) {
      return 'OctoEverywhere returned: ${errorReason.message}';
    } else if (errorReason != null) {
      return errorReason.toString();
    }
    return 'Error while trying to connect. Please retry later.';
  }

  bool get errorIsOctoSupportedExpired {
    var jsonRpcClient = ref.read(jrpcClientSelectedProvider);
    Exception? errorReason = jsonRpcClient.errorReason;
    if (errorReason is! OctoEverywhereHttpException) {
      return false;
    }

    return errorReason.statusCode == 605;
  }

  onRestartKlipperPressed() {
    ref.read(klipperServiceSelectedProvider).restartKlipper();
  }

  onRestartMCUPressed() {
    ref.read(klipperServiceSelectedProvider).restartMCUs();
  }

  onEditPrinter() async {
    Machine? machine = await ref.read(selectedMachineProvider.future);
    if (machine != null) {
      ref.read(goRouterProvider).pushNamed(AppRoute.printerEdit.name, extra: machine);
    }
  }

  onGoToOE() async {
    var oeURI = Uri.parse(
      'https://octoeverywhere.com/appportal/v1/nosupporterperks?moonraker=true&appid=mobileraker',
    );
    if (await canLaunchUrl(oeURI)) {
      await launchUrl(oeURI, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $oeURI';
    }
  }
}
