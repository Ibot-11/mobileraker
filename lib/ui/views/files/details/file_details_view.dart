import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mobileraker/dto/files/gcode_file.dart';
import 'package:mobileraker/ui/views/files/details/file_details_viewmodel.dart';
import 'package:mobileraker/util/time_util.dart';
import 'package:stacked/stacked.dart';

class FileDetailView extends ViewModelBuilderWidget<FileDetailsViewModel> {
  const FileDetailView({Key? key, required this.file}) : super(key: key);
  final GCodeFile file;

  @override
  Widget builder(
      BuildContext context, FileDetailsViewModel model, Widget? child) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     file.name,
      //     overflow: TextOverflow.fade,
      //   ),
      // ),
      body: CustomScrollView(
        slivers: [
          SliverLayoutBuilder(builder: (context, constraints) {
            return SliverAppBar(
              expandedHeight: 220,
              floating: true,
              actions: [
                IconButton(
                  onPressed:
                      model.preHeatAvailable ? model.preHeatPrinter : null,
                  icon: Icon(
                    FlutterIcons.fire_alt_faw5s,
                  ),
                  tooltip: 'Preheat',
                )
              ],
              // title: Text(
              //   file.name,
              //   overflow: TextOverflow.fade,
              //   maxLines: 1,
              // ),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: CachedNetworkImage(
                  imageUrl:
                      '${model.curPathToPrinterUrl}/${file.parentPath}/${file.bigImagePath}',
                  imageBuilder: (context, imageProvider) => Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Image(
                        image: imageProvider,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      Container(
                          width: double.infinity,
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                                top: const Radius.circular(8.0)),
                            color: Theme.of(context)
                                .colorScheme
                                .primaryVariant
                                .withOpacity(0.8),
                          ),
                          child: Text(
                            file.name,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 5,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2
                                ?.copyWith(color: Colors.white),
                          ))
                    ],
                  ),
                  placeholder: (context, url) => Icon(Icons.insert_drive_file),
                  errorWidget: (context, url, error) => Column(
                    children: [
                      Icon(Icons.file_present),
                      Container(
                          width: double.infinity,
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                                top: const Radius.circular(8.0)),
                            color: Theme.of(context)
                                .colorScheme
                                .primaryVariant
                                .withOpacity(0.8),
                          ),
                          child: Text(
                            file.name,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 5,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2
                                ?.copyWith(color: Colors.white),
                          ))
                    ],
                  ),
                ),
              ),
            );
          }),
          SliverToBoxAdapter(
            child: Column(children: [
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(FlutterIcons.printer_3d_nozzle_outline_mco),
                      title: Text('General'),
                    ),
                    Divider(),
                    PropertyTile(
                        title: 'Path',
                        subtitle: '${file.parentPath}/${file.name}'),
                    PropertyTile(
                      title: 'Last Modified',
                      subtitle: model.formattedLastModified,
                    ),
                    PropertyTile(
                      title: ('Last Printed'),
                      subtitle: (file.printStartTime != null)
                          ? model.formattedLastPrinted
                          : 'No Data',
                    ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(FlutterIcons.tags_ant),
                      title: Text('GCode Meta Data'),
                    ),
                    Divider(),
                    PropertyTile(
                      title: 'Estimated Print Time',
                      subtitle:
                          '${secondsToDurationText(file.estimatedTime ?? 0)}, ETA: ${model.potentialEta}',
                    ),
                    PropertyTile(
                      title: 'Used Slicer',
                      subtitle: '${file.slicer} (v${file.slicerVersion})',
                    ),
                    PropertyTile(
                      title: 'Layer Height',
                      subtitle:
                          'First Layer: ${file.firstLayerHeight?.toStringAsFixed(2)} mm\n'
                          'Others: ${file.layerHeight?.toStringAsFixed(2)} mm',
                    ),
                    PropertyTile(
                      title: 'First Layer - Temperatures',
                      subtitle:
                          'Extruder: ${file.firstLayerTempExtruder?.toStringAsFixed(0)}°C\n'
                          'Bed: ${file.firstLayerTempBed?.toStringAsFixed(0)}°C',
                    ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(FlutterIcons.chart_bar_mco),
                      title: Text('Statistics'),
                    ),
                    Divider(),
                    PropertyTile(
                      title: 'WIP',
                      subtitle: '',
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 100,
              )
            ]),
          )
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor:
            (model.canStartPrint) ? null : Theme.of(context).disabledColor,
        onPressed: (model.canStartPrint) ? model.onStartPrintTap : null,
        icon: Icon(FlutterIcons.printer_3d_nozzle_mco),
        label: Text('Print'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  FileDetailsViewModel viewModelBuilder(BuildContext context) =>
      FileDetailsViewModel(file);
}

class PropertyTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const PropertyTile({Key? key, required this.title, required this.subtitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var subtitleTheme = textTheme.bodyText2
        ?.copyWith(fontSize: 13, color: textTheme.caption?.color);
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.left,
          ),
          SizedBox(
            height: 2,
          ),
          Text(
            subtitle,
            style: subtitleTheme,
            textAlign: TextAlign.left,
          )
        ],
      ),
    );
  }
}