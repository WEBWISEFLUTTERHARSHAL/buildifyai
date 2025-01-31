import 'dart:async';
import 'dart:ui';
import 'package:Buildify_AI/utils/api_calls.dart';
import 'package:Buildify_AI/utils/colors.dart';
import 'package:Buildify_AI/utils/strings.dart';
import 'package:Buildify_AI/widgets/generalAppBar.dart';
import 'package:Buildify_AI/widgets/generalButton.dart';
import 'package:Buildify_AI/widgets/generalDropdown.dart';
import 'package:Buildify_AI/widgets/generalPopUp.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrCodeScanner extends StatefulWidget {
  const QrCodeScanner({super.key});

  @override
  State<QrCodeScanner> createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner>
    with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController();
  StreamSubscription<Object?>? _subscription;
  bool isScanned = false;
  String? qrCodeData = '';
  String? taskValue = null;

  void _handleBarcode(BarcodeCapture? event) {
    final String code = event?.barcodes.first.rawValue ?? '---';
    print('Barcode found! $code');
  }

  @override
  void initState() {
    super.initState();
    // Start listening to lifecycle changes.
    WidgetsBinding.instance.addObserver(this);
    // Start listening to the barcode events.
    _subscription = controller.barcodes.listen(_handleBarcode);
    // Finally, start the scanner itself.
    unawaited(controller.start());
  }

  @override
  Future<void> dispose() async {
    // Stop listening to lifecycle changes.
    WidgetsBinding.instance.removeObserver(this);
    // Stop listening to the barcode events.
    unawaited(_subscription?.cancel());
    _subscription = null;
    // Dispose the widget itself.
    super.dispose();
    // Finally, dispose of the controller.
    await controller.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the controller is not ready, do not try to start or stop it.
    // Permission dialogs can trigger lifecycle changes before the controller is ready.
    if (!controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        // Restart the scanner when the app is resumed.
        // Don't forget to resume listening to the barcode events.
        _subscription = controller.barcodes.listen(_handleBarcode);
        unawaited(controller.start());
      case AppLifecycleState.inactive:
        // Stop the scanner when the app is paused.
        // Also stop the barcode events subscription.
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller.stop());
    }
  }

  // Function to handle QR code detection
  void _onDetect(BarcodeCapture capture) async {
    if (!isScanned) {
      final barcode = capture.barcodes.first;
      setState(() {
        isScanned = true;
        qrCodeData = barcode.rawValue;
      });
      await controller.stop();
      showDialog(
        context: context,
        builder: (context) {
          return GeneralPopUp(
            title: 'QR Code Detected',
            message: 'QR Code Data: $qrCodeData',
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetSize = 300.0;
    return Scaffold(
      backgroundColor: lightBlueTheme,
      appBar: GeneralAppbar(title: strings.scan),
      body: FutureBuilder(
        future: fetchTaskDropdown(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  backgroundColor: progressBg,
                  color: darkBlueTheme,
                  strokeCap: StrokeCap.round,
                  strokeWidth: 3,
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(strings.genericDataFetchError),
            );
          } else if (snapshot.data.runtimeType == String) {
            return Center(
              child: Text(snapshot.data.toString()),
            );
          } else {
            return Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: _onDetect,
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: SizedBox.shrink(),
                  ),
                ),
                // Cutout area that is NOT blurred
                Column(
                  children: [
                    Flexible(
                      child: Center(
                        child: Container(
                          height: targetSize,
                          width: targetSize,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: MobileScanner(
                              controller: controller,
                              onDetect: _onDetect,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.selectTask,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: white,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GeneralDropdown(
                              hintText: strings.select,
                              selectedValue: ValueNotifier(taskValue),
                              onChanged: (value) {
                                taskValue = value;
                              },
                              items: snapshot.data!
                                  .map(
                                    (e) {
                                      return DropdownMenuItem(
                                        value: e.id,
                                        child: Text(e.name),
                                      );
                                    },
                                  )
                                  .toList()
                                  .cast<DropdownMenuItem>(),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            GeneralButton(
                              text: strings.next,
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
