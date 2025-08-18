import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:torch_light/torch_light.dart';
import 'morse.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool active = false;
  int onTime = 1000;
  int offTime = 1000;
  int cycleTime = 1000;
  int pageIndex = 0;
  int segmentsCount = 0;
  String Message = "";
  bool torch = false;
  Set<int> selected = Set();
  Future<void>? runBlink() async {
    while(active){
        await TorchLight.enableTorch();
        await Future.delayed(Duration(milliseconds: onTime));
        await TorchLight.disableTorch();
        await Future.delayed(Duration(milliseconds: offTime));
    }
    await TorchLight.disableTorch();
  }
  Future<void> runRythm() async {
      while(active){
        int count = 0;
        switch(segmentsCount){
          case 0:
            count = 4;
            break;
          case 1:
            count = 8;
            break;
          case 2:
            count = 16;
            break;
        }
        for(int i=0; i<count&&active; i++){
          if(selected.contains(i)&&!torch){
            await TorchLight.enableTorch();
            torch = true;
          }
          else if(!selected.contains(i)&&torch){
            await TorchLight.disableTorch();
            torch = false;
          }
          await Future.delayed(Duration(milliseconds: cycleTime));
        }
      }
      await TorchLight.disableTorch();
  }
  Future<void> runMorse() async{
    String message = Message.toLowerCase();
    List<MChar> durations = [];
    message.split('').forEach(
     (item){
       if(Morse.characters.containsKey(item)){
         Morse.characters[item]?.forEach((x){
           if(x){
             durations.addAll([MChar(true, 3),MChar(false, 1)]);
           }
           else{
             durations.addAll([MChar(true, 1),MChar(false, 1)]);
           }
         });
         durations.add(MChar(false, 2));
       }
       else if(item == " "){
         durations.add(MChar(false, 4));
       }
    });
    for(int i = 0;i < durations.length&&active;i++ ){
     var item = durations[i];
     if(item.isOn){
       await TorchLight.enableTorch();
       await Future.delayed(Duration(milliseconds: item.blocks*cycleTime));
       await TorchLight.disableTorch();
     }
     else {
       await Future.delayed(Duration(milliseconds: item.blocks*cycleTime));
     }
    }

   active = false;
   setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    //runBlink();
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Advanced Torch'),
      ),
        bottomNavigationBar: NavigationBar(
          height: 75,
          backgroundColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          selectedIndex: pageIndex,
          onDestinationSelected: (int index){
            active = false;
            setState(() {
              pageIndex = index;
            });
          },
          labelTextStyle: WidgetStatePropertyAll<TextStyle>(TextStyle(color: Colors.black,fontSize: 15)),
          destinations: [
            NavigationDestination(icon: Icon(Icons.change_circle,color: Color(0xFF1B7D7F)), label: 'Simple'),
            NavigationDestination(icon: Icon(Icons.calendar_view_month,color: Color(0xFF1B7D7F)), label: 'Rythm'),
            NavigationDestination(icon: Icon(Icons.power_input,color: Color(0xFF1B7D7F)), label: 'Morse'),
          ],
        ),
      body:<Widget>[Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                Text(active?'On':'Off'),
                Switch(
                    value: active,
                    onChanged: (x) async {
                      setState(()  {
                        active = x;
                      });
                      if(x){
                        unawaited(runBlink());
                      }
                    }
                ),
              ],
            ),
            Padding(padding: EdgeInsets.all(24)),
            Text('Off Duration'),
            Slider(
                label: offTime.toString(),
                value: offTime.toDouble(),
                year2023: false,
                max: 10000,
                min: 0,
                divisions: 1000,
                onChanged: (x){
                  setState(() {
                    offTime=x.toInt();
                });
                }
            ),
            Text('${offTime/1000}s'),
            Padding(padding: EdgeInsets.all(24)),
            Text('On Duration'),
            Slider(
                label: onTime.toString(),
                value: onTime.toDouble(),
                year2023: false,
                max: 10000,
                min: 0,
                divisions: 1000,
                onChanged: (x){
                  setState(() {
                    onTime=x.toInt();
                  });
                }
            ),
            Text('${onTime/1000}s'),
          ],
        ),
      ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 16,right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Text(active?'On':'Off'),
                    Switch(
                        value: active,
                        onChanged: (x) async {
                          setState(()  {
                            active = x;
                          });
                          if(x){
                            unawaited(runRythm());
                          }
                          else{
                            TorchLight.disableTorch();
                          }
                        }
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.all(24)),
                SegmentedButton(
                  multiSelectionEnabled: true,
                  emptySelectionAllowed: true,
                  showSelectedIcon: false,
                  segments: [[
                      ButtonSegment<int>(value: 0,label: Text('1')),
                      ButtonSegment<int>(value: 1,label: Text('2')),
                      ButtonSegment<int>(value: 2,label: Text('3')),
                      ButtonSegment<int>(value: 3,label: Text('4')),
                  ],
                    [
                      ButtonSegment<int>(value: 0,label: Text('1')),
                      ButtonSegment<int>(value: 1,label: Text('2')),
                      ButtonSegment<int>(value: 2,label: Text('3')),
                      ButtonSegment<int>(value: 3,label: Text('4')),
                      ButtonSegment<int>(value: 4,label: Text('5')),
                      ButtonSegment<int>(value: 5,label: Text('6')),
                      ButtonSegment<int>(value: 6,label: Text('7')),
                      ButtonSegment<int>(value: 7,label: Text('8')),
                    ],
                    [
                      ButtonSegment<int>(value: 0,label: Text('1')),
                      ButtonSegment<int>(value: 1,label: Text('2')),
                      ButtonSegment<int>(value: 2,label: Text('3')),
                      ButtonSegment<int>(value: 3,label: Text('4')),
                      ButtonSegment<int>(value: 4,label: Text('5')),
                      ButtonSegment<int>(value: 5,label: Text('6')),
                      ButtonSegment<int>(value: 6,label: Text('7')),
                      ButtonSegment<int>(value: 7,label: Text('8')),
                    ]
                  ][segmentsCount],
                  selected: selected,
                  onSelectionChanged:(x){
                    setState(() {selected=x;});
                    },
                ),
                Visibility(
                  visible: segmentsCount==2,
                  child: SegmentedButton(
                  multiSelectionEnabled: true,
                  emptySelectionAllowed: true,
                  showSelectedIcon: false,
                  segments:
                  [
                      ButtonSegment<int>(value: 8,label: Text('9')),
                      ButtonSegment<int>(value: 9,label: Text('10')),
                      ButtonSegment<int>(value: 10,label: Text('11')),
                      ButtonSegment<int>(value: 11,label: Text('12')),
                      ButtonSegment<int>(value: 12,label: Text('13')),
                      ButtonSegment<int>(value: 13,label: Text('14')),
                      ButtonSegment<int>(value: 14,label: Text('15')),
                      ButtonSegment<int>(value: 15,label: Text('16')),
                  ],
                  selected: selected,
                  onSelectionChanged:(x)=> setState(() {selected=x;}),
                ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    Text('Blocks'),
                    DropdownButton<int>(
                      value: segmentsCount,
                        items: [
                          DropdownMenuItem(child: Text('4'),value: 0 ,),
                          DropdownMenuItem(child: Text('8'),value: 1 ,),
                          DropdownMenuItem(child: Text('16'),value: 2 ,)
                        ],
                        onChanged: (x){
                        setState((){segmentsCount = x!;});
                        if(x==0){
                          selected.removeWhere((x)=>x>3);
                        }
                        else if(x==1){
                          selected.removeWhere((x)=>x>7);
                        }
                      }
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.all(24)),
                Text('Duration of one Block'),
                Slider(
                    label: cycleTime.toString(),
                    value: cycleTime.toDouble(),
                    year2023: false,
                    max: 1000,
                    min: 0,
                    divisions: 1000,
                    onChanged: (x){
                      setState(() {
                        cycleTime=x.toInt();
                      });
                    }
                ),
                Text('${cycleTime/1000}s')
              ],
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              Text('Morse Code',style: TextStyle(fontSize: 35),),
              Padding(padding: EdgeInsets.all(8)),
              Text('Your Text'),
              Padding(
                padding: const EdgeInsets.only(left:16.0,right:16.0),
                child: SizedBox(
                  height: 150,
                  child: TextField(
                    onChanged: (x){ Message = x; },
                    maxLength: 255,
                    minLines: null,
                    maxLines: null,
                    textAlignVertical: TextAlignVertical(y:-1),
                    expands: true,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black),borderRadius: BorderRadius.circular(16)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,strokeAlign: 3),borderRadius: BorderRadius.circular(16)),
                        counterStyle: TextStyle(color: Colors.black,fontSize: 15)
                    ),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(24)),
              Text('Duration of one Block'),
              Slider(
                  value: cycleTime.toDouble(),
                  year2023: false,
                  max: 1000,
                  min: 0,
                  divisions: 100,
                  onChanged: (x){
                    setState(() {
                      cycleTime = x.toInt();
                    });
                  }
              ),
              Text('${cycleTime/1000}s'),
              TextButton.icon(
                  onPressed: () async {
                    if(active){
                      setState(() {
                        active = false;
                      });
                    }
                    else{
                      setState(() {
                        active = true;
                      });
                      unawaited(runMorse());
                    }
                  },
                  label: !active? Text('Start'):Text('Stop'),
                  icon: !active? Icon(Icons.play_arrow_outlined): Icon(Icons.stop),
              ),
            ],
          ),
        )
      ][pageIndex]
    );
  }
}



