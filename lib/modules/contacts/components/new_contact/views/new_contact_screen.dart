import 'package:bankdroid/common/widgets/loading_blur_wdt.dart';
import 'package:bankdroid/modules/contacts/components/new_contact/view_model/new_contact_view_model.dart';
import 'package:bankdroid/modules/contacts/components/new_contact/views/new_contact_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewContactScreen extends StatelessWidget {
  static const String route = '/contact/new';
  final obj;

  const NewContactScreen({Key key, this.obj});

  NewContactViewModel _createViewModel(BuildContext context) {
    return NewContactViewModel(obj: this.obj);
  }

  Widget _buildStack({@required BuildContext context, @required NewContactViewModel viewModel}) {
    List<Widget> stackList = new List<Widget>();
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    stackList.add(
      new Center(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              new Icon(Icons.account_circle, size: 96,),
              new Text('Nuevo Contacto', style: Theme.of(context).textTheme.subtitle1,),
              new Container(height: isLandscape ? 0 : 60,),
              new NewContactForm(),
            ],
          ),
        ),
      ),
    );

    if(viewModel.loading) {
      stackList.add(
        LoadingBlurWdt()
      );
    }

    return Stack(
      key: Key('new_contact_page_stack_key'),
      children: stackList,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: new Text('Nuevo Contacto'),
      ),
      body: ChangeNotifierProvider(
        create: _createViewModel,
        child: Consumer<NewContactViewModel>(
          builder: (context, viewModel, child) {

//            if(viewModel.normal) {
//              _scheduleLoadService(context, viewModel);
//              return Center(child: CircularProgressIndicator());
//            }
            return _buildStack(context: context, viewModel: viewModel);
          },
        ),
      ),
    );
  }
}
