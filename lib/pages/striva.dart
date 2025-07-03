import 'package:flutter/material.dart';
import 'package:pacer/components/custom_button.dart';
import 'package:pacer/components/distance_input_field.dart';
import 'package:pacer/components/time_input_field.dart';

class Striva extends StatefulWidget {
  const Striva({super.key});

  @override
  State<Striva> createState() => _StrivaState();
}

class _StrivaState extends State<Striva> {
  final distance = TextEditingController();
  final hours = TextEditingController();
  final minutes = TextEditingController();
  final seconds = TextEditingController();

  bool unitswitch = false; // false = km, true = mi
  bool isHoursError = false;
  bool isMinutesError = false;
  bool isSecondsError = false;

  String metricspeed = '0.00', imperialspeed = '0.00';
  String metricpace = '0:00 /', imperialpace = '0:00 /';

  double distanceKm = 0.0;
  double distanceMi = 0.0;
  double rawInputDistanceKm = 0.0;

  void resetFields() {
    distance.clear();
    hours.clear();
    minutes.clear();
    seconds.clear();
    distanceKm = 0.0;
    distanceMi = 0.0;
    rawInputDistanceKm = 0.0;
    setState(() {
      metricspeed = '0.00';
      imperialspeed = '0.00';
      metricpace = '0:00 /';
      imperialpace = '0:00 /';
      isHoursError = false;
      isMinutesError = false;
      isSecondsError = false;
    });
  }

  void calculatePaceAndSpeed() {
    final d = distance.text.isEmpty ? '0' : distance.text;
    final h = hours.text.isEmpty ? '0' : hours.text;
    final m = minutes.text.isEmpty ? '0' : minutes.text;
    final s = seconds.text.isEmpty ? '0' : seconds.text;

    final int hourVal = int.tryParse(h) ?? -1;
    final int minVal = int.tryParse(m) ?? -1;
    final int secVal = int.tryParse(s) ?? -1;

    isHoursError = hourVal < 0 || hourVal > 24;
    isMinutesError = minVal < 0 || minVal > 59;
    isSecondsError = secVal < 0 || secVal > 59;

    if (isHoursError || isMinutesError || isSecondsError) return;

    final totalSeconds = hourVal * 3600 + minVal * 60 + secVal;
    final inputDistance = double.tryParse(d) ?? 0.0;

    if (unitswitch) {
      distanceMi = inputDistance;
      rawInputDistanceKm = inputDistance * 1.609344;
      distanceKm = rawInputDistanceKm;
    } else {
      distanceKm = inputDistance;
      rawInputDistanceKm = distanceKm;
      distanceMi = distanceKm * 0.621371;
    }

    if (totalSeconds == 0 || distanceKm == 0) {
      metricspeed = '0.00';
      imperialspeed = '0.00';
      metricpace = '0:00 /';
      imperialpace = '0:00 /';
      return;
    }

    final kph = (distanceKm * 1000) / totalSeconds * 3.6;
    final mph = kph * 0.621371;
    metricspeed = kph.toStringAsFixed(2);
    imperialspeed = mph.toStringAsFixed(2);

    final paceKmSec = totalSeconds / distanceKm;
    final paceMiSec = totalSeconds / distanceMi;

    final minKm = (paceKmSec / 60).floor();
    final secKm = (paceKmSec % 60).round();
    metricpace = '$minKm:${secKm.toString().padLeft(2, '0')} /';

    final minMi = (paceMiSec / 60).floor();
    final secMi = (paceMiSec % 60).round();
    imperialpace = '$minMi:${secMi.toString().padLeft(2, '0')} /';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width > 400
                  ? 400
                  : double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: const [
                        Expanded(child: Divider(color: Colors.white)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "striva",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.white)),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 220,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            variableContainer([
                              customLabel("Time:"),
                              TimeInputField(controller: hours, hint: "00"),
                              customUnits("h"),
                              TimeInputField(controller: minutes, hint: "00"),
                              customUnits("m"),
                              TimeInputField(controller: seconds, hint: "00"),
                              customUnits("s"),
                            ]),
                            variableContainer([
                              customLabel("Distance:"),
                              DistanceInputField(
                                  controller: distance, hint: "0.0"),
                              customUnits(unitswitch ? "mi" : "km")
                            ]),
                            variableContainer([
                              customLabel("Speed:  "),
                              customResult(
                                  unitswitch ? imperialspeed : metricspeed),
                              customUnits(unitswitch ? "mph" : "kph")
                            ]),
                            variableContainer([
                              customLabel("Pace:  "),
                              customResult(
                                  unitswitch ? imperialpace : metricpace),
                              customUnits(unitswitch ? "mi" : "km")
                            ]),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 220,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              text: "ac",
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                setState(resetFields);
                              },
                              bg: Colors.redAccent,
                            ),
                            CustomButton(
                              text: "km",
                              onPressed: () {
                                if (unitswitch) {
                                  distance.text =
                                      rawInputDistanceKm.toStringAsFixed(2);
                                  unitswitch = false;
                                  calculatePaceAndSpeed();
                                }
                                FocusScope.of(context).unfocus();
                                setState(() {});
                              },
                            ),
                            CustomButton(
                              text: "mi",
                              onPressed: () {
                                if (!unitswitch) {
                                  final rawMi = rawInputDistanceKm * 0.621371;
                                  distance.text = rawMi.toStringAsFixed(2);
                                  unitswitch = true;
                                  calculatePaceAndSpeed();
                                }
                                FocusScope.of(context).unfocus();
                                setState(() {});
                              },
                            ),
                            CustomButton(
                              text: "=",
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                setState(calculatePaceAndSpeed);
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  if (isHoursError)
                    errorMessage("Hours must be between 0 - 24"),
                  if (isMinutesError)
                    errorMessage("Minutes must be between 0 - 59"),
                  if (isSecondsError)
                    errorMessage("Seconds must be between 0 - 59"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget customLabel(String label) =>
      Text(label, style: const TextStyle(fontSize: 18));
  Widget customResult(String result) => Text(result,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  Widget customUnits(String unit) => Text(unit,
      style: const TextStyle(fontSize: 16, color: Color(0xffFF9500)));

  Widget variableContainer(List<Widget> children) {
    return SizedBox(height: 50, child: Row(spacing: 2, children: children));
  }

  Widget errorMessage(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Container(
        height: 30,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1, color: Colors.red),
        ),
        child: Center(
          child: Text(message,
              style: const TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ),
    );
  }
}
