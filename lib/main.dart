import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart' as xml;
import 'package:svg_path_parser/svg_path_parser.dart';

void main() {
  runApp(MyApp());
}

late Set<String> states = {};
late Map<String, String> state_path_map = {}, _state_color_map = {};

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'India',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'India'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Set<String> pressedStates = {};
  String pressedComponent = "Press states!!";
  Future<void> loadSvgImage(
      {required bool back, required String svgImage}) async {
    String generalString = await rootBundle.loadString(svgImage);

    final document = xml.XmlDocument.parse(generalString);
    final paths = document.findAllElements('path');

    paths.forEach((element) {
      String partName = element.getAttribute('id').toString();
      String partPath = element.getAttribute('d').toString();
      String partColor = element.getAttribute('fill').toString();
      print(partName);
      print(partPath);
      states.add(partName);
      state_path_map[partName] = partPath;
      _state_color_map[partName] = partColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String svgAsString = 'images/india.svg';
    loadSvgImage(back: false, svgImage: svgAsString);
    // This method is rerun every time setState is called
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double navBarHeight =
        Theme.of(context).platform == TargetPlatform.android ? 56.0 : 44.0;
    double safeZoneHeight = MediaQuery.of(context).padding.bottom;

    double scaleFactor = 0.5;
    double mheight = 416;
    double mwidth = 366;
    double x = (width / 2.0) - (mwidth / 2.0);
    double y = (height / 2.0) -
        (mheight / 2.0) -
        (safeZoneHeight / 2.0) -
        navBarHeight;
    Offset offset = Offset(x, y);

    return Scaffold(
        appBar: AppBar(
          title: Text(pressedComponent),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
            child: Transform.scale(
                scale: (height / mheight) * scaleFactor,
                child: Transform.translate(
                    offset: offset, child: Stack(children: _buildMap())))));
  }

  List<Widget> _buildMap() {
    List<Widget> state_widgets = [];
    for (String state in states) {
      state_widgets.add(_buildStateWidget(state));
    }
    return state_widgets;
  }

  Widget _buildStateWidget(String state) {
    return ClipPath(
        child: Stack(children: <Widget>[
          CustomPaint(painter: PathPainter(state)),
          Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () => _statePressed(state),
                  child: Container(
                      color: pressedStates.contains(state)
                          ? colorFromHex(_state_color_map[state]!)
                          : Colors.transparent)))
        ]),
        clipper: PathClipper(state));
  }

  void _statePressed(String state) {
    setState(() {
      pressedComponent = state;
      pressedStates.add(state);
      print(state);
    });
  }

  static Color colorFromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class PathPainter extends CustomPainter {
  final String _state;
  PathPainter(this._state);

  @override
  void paint(Canvas canvas, Size size) {
    Path path = parseSvgPath(state_path_map[_state] as String) as Path;
    print(state_path_map[_state] as String);
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.black
          ..strokeWidth = 2.0);
  }

  @override
  bool shouldRepaint(PathPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(PathPainter oldDelegate) => false;
}

class PathClipper extends CustomClipper<Path> {
  final String _state;
  PathClipper(this._state);

  @override
  Path getClip(Size size) {
    Path p = parseSvgPath(state_path_map[_state] as String) as Path;
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
