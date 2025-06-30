import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Pacer extends StatefulWidget {
  const Pacer({super.key});
  @override
  State<Pacer> createState() => _PacerState();
}

class _PacerState extends State<Pacer> {
  late Timer _timer;
  Duration _remaining = Duration();
  final targetDate = DateTime(2025, 10, 19);

  final distance = TextEditingController();
  final hours = TextEditingController();
  final minutes = TextEditingController();
  final seconds = TextEditingController();

  bool unitswitch = false;

  double speed = 0.0;
  String metricspeed = '0.00 kph', imperialspeed = '0.00 mph';
  String metricpace = '0:00/km', imperialpace = '0:00/mi';

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    _timer = Timer.periodic(
        const Duration(seconds: 1), (_) => _updateRemainingTime());
  }

  void _updateRemainingTime() {
    setState(() {
      _remaining = targetDate.difference(DateTime.now());
      if (_remaining.isNegative) _timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _resetFields() {
    distance.clear();
    hours.clear();
    minutes.clear();
    seconds.clear();
    setState(() {
      speed = 0.0;
      metricspeed = '0.00 kph';
      imperialspeed = '0.00 mph';
      metricpace = '0:00/km';
      imperialpace = '0:00/mi';
    });
  }

  void _calculatePaceAndSpeed() {
    final d = distance.text.isEmpty ? '0' : distance.text;
    final h = hours.text.isEmpty ? '0' : hours.text;
    final m = minutes.text.isEmpty ? '0' : minutes.text;
    final s = seconds.text.isEmpty ? '0' : seconds.text;

    final distKm = unitswitch ? (double.parse(d) * 1.609344) : double.parse(d);
    speed = _calculateSpeed(distKm, h, m, s);

    metricspeed = '${speed.toStringAsFixed(2)} kph';
    imperialspeed = '${(speed * 0.621371).toStringAsFixed(2)} mph';

    if (speed == 0) {
      metricpace = '0:00/km';
      imperialpace = '0:00/mi';
      return;
    }

    final paceKm = 60 / speed;
    final minKm = paceKm.floor();
    final secKm = ((paceKm - minKm) * 60).round();
    metricpace = '$minKm:${secKm.toString().padLeft(2, '0')}/km';

    final paceMi = paceKm * 1.60934;
    final minMi = paceMi.floor();
    final secMi = ((paceMi - minMi) * 60).round();
    imperialpace = '$minMi:${secMi.toString().padLeft(2, '0')}/mi';
  }

  double _calculateSpeed(double distanceKm, String h, String m, String s) {
    final totalSeconds = int.parse(h) * 3600 + int.parse(m) * 60 + int.parse(s);
    if (totalSeconds == 0 || distanceKm == 0) return 0.0;
    final result = (distanceKm * 1000) / totalSeconds * 3.6;
    return result;
  }

  void _toggleUnit() {
    setState(() {
      final value = double.tryParse(distance.text) ?? 0.0;
      distance.text = !unitswitch
          ? (value * 0.6213711922 + 1e-10).toStringAsFixed(2)
          : (value * 1.609344 + 1e-10).toStringAsFixed(2);
      unitswitch = !unitswitch;
      _calculatePaceAndSpeed();
    });
  }

  Row _formatDuration(Duration d) {
    if (d.isNegative) {
      return const Row(children: [Text('Race Day! Good luck!')]);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _timeColumn('Days', d.inDays, Colors.green, d.inDays / 365),
        _timeColumn(
            'Hours', d.inHours % 24, Colors.blue, (d.inHours % 24) / 24),
        _timeColumn(
            'Minutes', d.inMinutes % 60, Colors.red, (d.inMinutes % 60) / 60),
        _timeColumn('Seconds', d.inSeconds % 60, Colors.yellow,
            (d.inSeconds % 60) / 60),
      ],
    );
  }

  Widget _timeColumn(String label, int value, Color color, double progress) {
    final barHeight = 40.0;
    return Row(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            Text('$value', style: const TextStyle(fontSize: 16)),
          ],
        ),
        SizedBox(width: 10),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 5,
              height: barHeight,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Container(
              width: 5,
              height: barHeight * progress.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6), topRight: Radius.circular(6)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: screenWidth > 440 ? 440 : double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading('Upcoming Race'),
                subheading('WFPS Run'),
                _formatDuration(_remaining),
                const SizedBox(height: 10),
                Column(children: [
                  SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Text('Distance: '),
                          SizedBox(
                            width: 100,
                            child:
                                _inputField('0.00', distance, isDecimal: true),
                          ),
                          Text(!unitswitch ? ' km' : ' mi'),
                        ]),
                        SizedBox(
                          child: ElevatedButton(
                            onPressed: _resetFields,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              elevation: 2,
                              shadowColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text('AC',
                                style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    child: Row(children: [
                      const Text('Time: '),
                      _timeInput(hours, 'hh'),
                      const Text(' : '),
                      _timeInput(minutes, 'mm'),
                      const Text(' : '),
                      _timeInput(seconds, 'ss'),
                    ]),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _labelValueRow('speed: ',
                                !unitswitch ? metricspeed : imperialspeed),
                            _labelValueRow('pace: ',
                                !unitswitch ? metricpace : imperialpace),
                          ]),
                      Column(children: [
                        _button(
                            !unitswitch ? 'metric' : 'imperial', _toggleUnit,
                            bg: !unitswitch
                                ? const Color(0xff505050)
                                : const Color(0xffb0b0b0),
                            elevation: !unitswitch ? 2 : 1),
                        _button(
                            'Calculate', () => setState(_calculatePaceAndSpeed),
                            bg: const Color(0xffFF9500)),
                      ])
                    ],
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String hint, TextEditingController controller,
      {bool isDecimal = false}) {
    return TextField(
      style: TextStyle(color: Color(0xffFF9500)),
      controller: controller,
      textAlign: TextAlign.center,
      keyboardType: isDecimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      inputFormatters: [
        LengthLimitingTextInputFormatter(7),
        FilteringTextInputFormatter.allow(
            RegExp(isDecimal ? r'^\d*\.?\d*' : r'\d+')),
      ],
      onTap: controller.clear,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xffb0b0b0))),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xffFF9500), width: 2.5)),
      ),
    );
  }

  Widget _timeInput(TextEditingController c, String hint) =>
      SizedBox(width: 50, child: _inputField(hint, c));

  Widget _button(String text, VoidCallback onPressed,
      {Color bg = Colors.blue, double elevation = 2}) {
    return SizedBox(
      width: 125,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: elevation,
          shadowColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _labelValueRow(String label, String value) => SizedBox(
        height: 65,
        child: Row(children: [
          Text(label),
          Text(
            value,
            style: TextStyle(color: Color(0xffFF9500)),
          ),
        ]),
      );
}

Widget heading(String label) {
  return Text(
    label,
    style: TextStyle(fontSize: 18),
  );
}

Widget subheading(String label) {
  return Text(
    label,
    style: TextStyle(fontSize: 16),
  );
}
