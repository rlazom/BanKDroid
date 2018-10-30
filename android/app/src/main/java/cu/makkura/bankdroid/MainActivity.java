package cu.makkura.bankdroid;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.provider.ContactsContract;
import android.util.Log;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import static android.content.ContentValues.TAG;

public class MainActivity extends FlutterActivity {

  private static final String CHANNEL = "cu.makkura.bankdroid/selectContacts";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {

              @Override
              public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                  try {
                      Context context = getActiveContext();
                      Intent intent = null;

                      switch (methodCall.method){
                          case "selectContacts": {
                              intent = selectContacts(methodCall);
                              break;
                          }
                          default: {
                              result.notImplemented();
                          }
                      }

                      Log.i(TAG, "Sending intent " + intent);
                      context.startActivity(intent);

                      result.success(null);
                  }
                  catch (Exception ex){
                      result.error(ex.getClass().getName(),ex.getMessage(),ex);
                  }
              }
            }
    );
  }

    private Intent selectContacts(MethodCall methodCall){
        Log.i(TAG, "Intent extra pan " + methodCall.argument("pan").toString());
        Log.i(TAG, "Intent extra pan_label " + methodCall.argument("pan_label").toString());

        Intent intent = new Intent(Intent.ACTION_INSERT_OR_EDIT);
        intent.setType(ContactsContract.Contacts.CONTENT_ITEM_TYPE);
        intent.putExtra(ContactsContract.Intents.Insert.PHONE, methodCall.argument("pan").toString());
        intent.putExtra(ContactsContract.Intents.Insert.PHONE_TYPE, methodCall.argument("pan_label").toString());

        return intent;
    }

    private Context getActiveContext() {
      return this.getApplicationContext();
    }
}
