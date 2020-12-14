import 'package:bankdroid/modules/main/view_model/main_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class MainView extends StatelessWidget {
  static const String route = '/';
  final GlobalKey<ScaffoldState> _mainScaffoldKey = new GlobalKey<ScaffoldState>();

  MainViewModel _createViewModel(BuildContext context) {
    return MainViewModel(mainScaffoldKey: _mainScaffoldKey);
  }

  void _scheduleLoadService(BuildContext context, MainViewModel viewModel) {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      await viewModel.loadData(context);
    });
  }

  Widget _buildSplash(BuildContext context) {
    List<Widget> stackList = new List<Widget>();
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    stackList.add(
      new Container(
        width: double.infinity,
        height: double.infinity,
        decoration: new BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    );

    stackList.add(
      new Center(
        child: new Padding(
          padding: new EdgeInsets.only(top: isLandscape ? 40.0 : 100.0, bottom: 24.0),
          child: SingleChildScrollView(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      new Image.asset('images/logo_apk.png', width: 100.0, alignment: Alignment.center,),
                      new SizedBox(
                        width: 120.0,
                        height: 120.0,
                        child: new CircularProgressIndicator(
                            key: Key('circular_loading'),
                            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor.withOpacity(0.6))
                        ),
                      ),
                    ],
                  )
                ),
                new Container(height: isLandscape ? 0 : 60,),
                new Text('Loading...', style: Theme.of(context).textTheme.caption,),
              ],
            ),
          ),
        ),
      ),
    );

//    stackList.add(
//        Align(
//            alignment: Alignment.bottomCenter,
//            child: new Padding(
//              padding: const EdgeInsets.all(16.0),
//              child: CubanEngineerLogo(),
//            )
//        )
//    );

    return Stack(
      key: Key('main_page_stack_key'),
      children: stackList,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _mainScaffoldKey,
      body: ChangeNotifierProvider(
        create: _createViewModel,
        child: Consumer<MainViewModel>(
          builder: (context, viewModel, child) {

            if(viewModel.normal) {
              _scheduleLoadService(context, viewModel);
              return _buildSplash(context);
            }
            return _buildSplash(context);
          },
        ),
      ),
    );
  }
}
