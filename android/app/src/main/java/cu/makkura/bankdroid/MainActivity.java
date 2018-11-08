package cu.makkura.bankdroid;

import android.annotation.TargetApi;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Context;
import android.content.Intent;
import android.content.res.AssetFileDescriptor;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.BaseColumns;
import android.provider.Contacts;
import android.provider.ContactsContract;
import android.util.Log;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

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
                      Object resultMethodData = null;
                      byte[] resultPhotoInputStream = null;

                      switch (methodCall.method){
                          case "selectContacts": {
                              intent = selectContacts(methodCall);

                              Log.i(TAG, "Sending intent " + intent);
                              context.startActivity(intent);
                              result.success(null);
                              break;
                          }
                          case "findContactByPhone": {
                              resultMethodData = findContactByPhone(methodCall);
                              result.success(resultMethodData);
                              break;
                          }
                          case "queryContactThumbnail": {
                              resultPhotoInputStream = queryContactThumbnail(methodCall);
                              result.success(resultPhotoInputStream);
                              break;
                          }
                          default: {
                              result.notImplemented();
                          }
                      }
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

    private String findContactByPhone(MethodCall methodCall){
        String phoneNumber = methodCall.argument("phone").toString();
        Log.i(TAG, "Search by phone: " + phoneNumber);

        Uri uri = Uri.withAppendedPath(ContactsContract.PhoneLookup.CONTENT_FILTER_URI, Uri.encode(phoneNumber));
        String name = "?";
        String label = "?";
        String photo_uri = "?";
        String photo_thumbnail_uri = "?";

        String contact = null;

        ContentResolver contentResolver = getContentResolver();
        Cursor contactLookup = contentResolver.query(uri, new String[] {
                BaseColumns._ID,
                ContactsContract.PhoneLookup.LABEL,
                ContactsContract.PhoneLookup.DISPLAY_NAME,
                ContactsContract.Data.PHOTO_URI,
                ContactsContract.Data.PHOTO_THUMBNAIL_URI
        }, null, null, null);

        try {
            if (contactLookup != null && contactLookup.getCount() > 0) {
                contactLookup.moveToNext();
                label = contactLookup.getString(contactLookup.getColumnIndex(ContactsContract.PhoneLookup.LABEL));
                name = contactLookup.getString(contactLookup.getColumnIndex(ContactsContract.Data.DISPLAY_NAME));
                photo_uri = contactLookup.getString(contactLookup.getColumnIndex(ContactsContract.Data.PHOTO_URI));
                photo_thumbnail_uri = contactLookup.getString(contactLookup.getColumnIndex(ContactsContract.Data.PHOTO_THUMBNAIL_URI));
                String contactId = contactLookup.getString(contactLookup.getColumnIndex(BaseColumns._ID));

                Log.i(TAG, "Phone number found on Contact: " + name);
                contact = "contactId: " + contactId + '|' + "name: " + name + '|' + "label: " + label + '|' + "photo_uri: " + photo_uri + '|' + "photo_thumbnail_uri: " + photo_thumbnail_uri;
            }
        } finally {
            if (contactLookup != null) {
                contactLookup.close();
            }
        }

        return contact;
    }

    @TargetApi(Build.VERSION_CODES.ECLAIR)
    private byte[] queryContactThumbnail(MethodCall methodCall) {
        String photo_thumbnail_uri = methodCall.argument("photo_thumbnail_uri").toString();
        Log.i(TAG, "Search photo thumbnail by photo_thumbnail_uri: " + photo_thumbnail_uri);

        Uri photoUri = Uri.parse(photo_thumbnail_uri);
        Log.i(TAG, "URI");
        Log.i(TAG, photoUri.toString());

        Cursor cursor = getContentResolver().query(photoUri,
                new String[] {ContactsContract.Contacts.Photo.PHOTO}, null, null, null);
        if (cursor == null) {
            return null;
        }
        try {
            if (cursor.moveToFirst()) {
                byte[] data = cursor.getBlob(0);
                if (data != null) {
                    Log.i(TAG, "Llego aki");
                    return data;
//                    return new ByteArrayInputStream(data);
                }
            }
        } finally {
            cursor.close();
        }
        return null;
    }
//    public static byte[] getBytesFromInputStream(InputStream is) throws IOException {
//        ByteArrayOutputStream os = new ByteArrayOutputStream();
//        byte[] buffer = new byte[0xFFFF];
//        for (int len = is.read(buffer); len != -1; len = is.read(buffer)) {
//            os.write(buffer, 0, len);
//        }
//        return os.toByteArray();
//    }
//    @TargetApi(Build.VERSION_CODES.ECLAIR)
//    private void queryContactPhoto() {
//        Uri uri = Uri.withAppendedPath(ContactsContract.AUTHORITY_URI, photoUri);
//
//        try {
//            AssetFileDescriptor fd = registrar.context().getContentResolver().openAssetFileDescriptor(
//                    uri, "r");
//            if (fd != null) {
//                InputStream stream = fd.createInputStream();
//                byte[] bytes = getBytesFromInputStream(stream);
//                stream.close();
//                result.success(bytes);
//            }
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
//    }

    private Context getActiveContext() {
      return this.getApplicationContext();
    }
}
