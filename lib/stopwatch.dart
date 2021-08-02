import 'dart:async';
import 'package:flutter/material.dart';

import 'platform_alert.dart';

class StopWatch extends StatefulWidget {
  static const route = '/stopwatch';
  final String name;
  final String email;

  const StopWatch({Key key, this.name, this.email}) : super(key: key);
  @override
  State createState() => StopWatchState();
}

class StopWatchState extends State<StopWatch> {
  int milliseconds = 0;
  int seconds = 0;
  final itemHeight = 60.0;
  final scrollController = ScrollController();
  Timer timer;
  final laps = <int>[];
  bool isTicking = false;

  void _onTick(Timer time) {
    setState(() {
      milliseconds += 100;
    });
  }
/*
  void _zerar() {
    setState(() {
      milliseconds = 0;
    });
  }*/

  void _reset() {
    setState(() {
      milliseconds = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    String name = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: _buildCounter(context)),
          Expanded(child: _buildHeader(context)),
          Expanded(child: _buildLapDisplay()),
        ],
      ),
    );
  }

  Widget _buildCounter(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Lap ${laps.length + 1}',
            style: Theme.of(context)
                .textTheme
                .subtitle1
                .copyWith(color: Colors.white),
          ),
          Text(
            _secondsText(milliseconds),
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(color: Colors.white),
          ),
          SizedBox(height: 20),
          _buildControls()
        ],
      ),
    );
  }

  Row _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
          child: Text('Start'),
          onPressed: isTicking ? null : _startTimer,
        ),
        SizedBox(width: 20),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
          ),
          child: Text('Lap'),
          onPressed: isTicking ? _lap : null,
        ),
        SizedBox(width: 20),
        Builder(
          builder: (context) => TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            child: Text('Stop'),
            onPressed: isTicking ? () => _stopTimer(context) : null,
          ),
        ),
        SizedBox(width: 20),
        ElevatedButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
          child: Text('Reset'),
          onPressed: !isTicking ? _reset : null,
        ),
      ],
    );
  }

  void _startTimer() {
    timer = Timer.periodic(Duration(milliseconds: 100), _onTick);
    setState(() {
      laps.clear();
      isTicking = true;
    });
  }

  void _stopTimer(BuildContext context) {
    timer.cancel();
    setState(() {
      isTicking = false;
    });
    // final totalRuntime = laps.fold(milliseconds, (total, lap) => total + lap);
    // final alert = PlatformAlert(
    //   title: 'Run Completed!',
    //   message: 'Total Run Time is ${_secondsText(totalRuntime)}.',
    // );
    // alert.show(context);
    final controller =
        showBottomSheet(context: context, builder: _buildRunCompleteSheet);

    Future.delayed(Duration(seconds: 5)).then((_) {
      controller.close();
    });
  }

  String _secondsText(int milliseconds) {
    final seconds = milliseconds / 1000;
    return '$seconds seconds';
  }

  void _lap() {
    scrollController.animateTo(
      itemHeight * laps.length,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
    setState(() {
      laps.add(milliseconds);
      milliseconds = 0;
    });
  }

  Widget _cabecalho() {
    return GridView.count(crossAxisCount: 3, children: [
      Text('Volta'),
      Text('Tempo das Voltas'),
      Text('Tempo Geral'),
    ]);
  }

  Widget _listViewBuilder() {
    return ListView.builder(
      controller: scrollController,
      itemExtent: itemHeight,
      itemCount: laps.length + 1,
      itemBuilder: (context, index) {
       /* if (index == 0) {
          return _cabecalho();
        }*/
        // index -= 1;
      //  index = 1;
        final lapMilliseconds = laps[index];
        var totalMilliseconds = 0;
        for (var i = 0; i <= index; i++) {
          totalMilliseconds += laps[i];
        }
        return _listItem(index, lapMilliseconds, totalMilliseconds);
      },
    );
  }

  Widget _buildLapDisplay() {
    return Scrollbar(child: _listViewBuilder());
  }

  Widget _listItem(index, lapMilliseconds, totalMilliseconds) {
    return GridView.count(crossAxisCount: 3, children: [
      _tile('Lap ${index + 1}'),
      _tile(_secondsText(lapMilliseconds)),
      _tile(_secondsText(totalMilliseconds)),
    ]);
  }

  Widget _tile(String text) {
    return Text(text);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Widget _buildRunCompleteSheet(BuildContext context) {
    final totalRuntime = laps.fold(milliseconds, (total, lap) => total + lap);
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
        child: Container(
      color: Theme.of(context).cardColor,
      width: double.infinity,
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Run Finished!', style: textTheme.headline6),
            Text('Total Run Time is ${_secondsText(totalRuntime)}.')
          ])),
    ));
  }

  Widget _buildHeader(BuildContext context) {
    return Table(
        defaultColumnWidth:
              FixedColumnWidth(MediaQuery.of(context).size.width / 3),
        border: TableBorder.all(
        color: Colors.black26, width: 1, style: BorderStyle.none),
        children: [
          TableRow(
              children: <Widget>[

                TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      height: 50,
                      color:Colors.green,
                      child: Center(child: Text('Volta'),
                      ),
                    ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Container(
                    height: 50,
                    color:Colors.green,
                    child: Center(child: Text('Tempo das voltas'),
                    ),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Container(
                    height: 50,
                    color:Colors.green,
                    child: Center(child: Text('Tempo Geral'),
                    ),
                  ),
                ),
          ]),
    ]);
  }
}
