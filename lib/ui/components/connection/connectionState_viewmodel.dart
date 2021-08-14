import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:mobileraker/WebSocket.dart';
import 'package:mobileraker/app/AppSetup.locator.dart';
import 'package:mobileraker/app/AppSetup.logger.dart';
import 'package:mobileraker/app/AppSetup.router.dart';
import 'package:mobileraker/dto/machine/PrinterSetting.dart';
import 'package:mobileraker/service/MachineService.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

const String _WebSocketStreamKey = 'websocket';
const String _SelectedPrinterStreamKey = 'selectedPrinter';
const String _DisplayStreamKey = 'display';


class ConnectionStateViewModel extends MultipleStreamViewModel {
  final _machineService = locator<MachineService>();
  final _snackBarService = locator<SnackbarService>();
  final _navigationService = locator<NavigationService>();
  final _logger = getLogger('ConnectionStateViewModel');
  WebSocketWrapper? _webSocket;
  PrinterSetting? _printerSetting;

  @override
  Map<String, StreamData> get streamsMap =>
      {
        _SelectedPrinterStreamKey:
        StreamData<PrinterSetting?>(_machineService.selectedPrinter),
        _DisplayStreamKey: StreamData<FGBGType>(FGBGEvents.stream),
        if (_printerSetting?.websocket != null) ...{
          _WebSocketStreamKey:
          StreamData<WebSocketState>(_webSocket!.stateStream)
        }
      };

  @override
  onData(String key, data) {
    super.onData(key, data);
    _logger.d('Data $key -> $data');
    switch (key) {
      case _SelectedPrinterStreamKey:
        PrinterSetting? nPrinterSetting = data;
        if (nPrinterSetting == _printerSetting) break;
        _printerSetting = nPrinterSetting;

        if (nPrinterSetting?.websocket != null) {
          _webSocket = nPrinterSetting?.websocket;
        }
        notifySourceChanged(clearOldData: true);
        break;
      case _WebSocketStreamKey:
        onDataWebSocket(data);
        break;
      case _DisplayStreamKey:
        switch (data) {
          case FGBGType.foreground:
            _webSocket?.ensureConnection();
            break;
          case FGBGType.background:
            break;
        }
        break;
    }
  }

  onDataWebSocket(WebSocketState data) {
    switch (data) {
      case WebSocketState.disconnected:
      // TODO: Handle this case.
        break;
      case WebSocketState.connecting:
      // _snackBarService.showSnackbar(
      //     message: "Trying to connect to Moonraker. Retry: ${_webSocket.retries}");
        break;
      case WebSocketState.connected:
      // _snackBarService.showSnackbar(message: "Connected to Moonraker");
        break;
      case WebSocketState.error:
        _snackBarService.showSnackbar(
            title: "Websocket",
            message: "Error while trying to connect:TODO");
        break;
    }
  }

  onRetryPressed() {
    _webSocket?.initCommunication();
  }

  onAddPrinterTap() {
    _navigationService.navigateTo(Routes.printersAdd);
  }

  WebSocketState get connectionState =>
      dataMap?[_WebSocketStreamKey] ?? WebSocketState.disconnected;

  bool get hasPrinter  => _machineService.printerAvailable();
}