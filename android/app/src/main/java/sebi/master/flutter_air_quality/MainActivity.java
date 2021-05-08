package sebi.master.flutter_air_quality;

import android.Manifest;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Bundle;
import android.os.IBinder;
import android.preference.PreferenceManager;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity implements
        SharedPreferences.OnSharedPreferenceChangeListener {
    private static final String TAG = "MainActivity";
    private static final String CHANNEL = "air.quality.widget";
    private static final String SharedPreferencesFileName = "AirQualityWidgetApp";
    private static boolean willStartService = false;
    // Used in checking for runtime permissions.
    private static final int REQUEST_PERMISSIONS_REQUEST_CODE = 34;

    // The BroadcastReceiver used to listen from broadcasts from the service.
    private MyReceiver myReceiver;

    // A reference to the service used to get location updates.
    private LocationUpdatesService mService = null;

    // Tracks the bound state of the service.
    private boolean mBound = false;

    // Monitors the state of the connection to the service.
    private final ServiceConnection mServiceConnection = new ServiceConnection() {

        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            LocationUpdatesService.LocalBinder binder = (LocationUpdatesService.LocalBinder) service;
            mService = binder.getService();
            mBound = true;
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            mService = null;
            mBound = false;
        }
    };

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler((call, result) -> {
            if (call.method.equals("getWaqiData")) {
                result.success(getWaqiDataFromSharedPref());
            } else if (call.method.equals("startLocationUpdates")) {
                if (!checkPermissions()) {
                    requestPermissions();
                    willStartService = true;
                } else {
                    mService.requestLocationUpdates();
                }
            } else if (call.method.equals("stopLocationUpdates")) {
                mService.removeLocationUpdates();
            } else if (call.method.equals("setCurrentLocation")) {
                String latitude = call.argument("latitude");
                String longitude = call.argument("longitude");
                Log.d(TAG, latitude + ", " + longitude);
                if (latitude != null && longitude != null && !latitude.equals("error") && !longitude.equals("error") && !latitude.equals("NaN") && !longitude.equals("NaN")) {
                    SharedPreferences.Editor sharedPreferencesEditor = getSharedPreferences(SharedPreferencesFileName, MODE_PRIVATE).edit();
                    sharedPreferencesEditor.putString("longitude", longitude).apply();
                    sharedPreferencesEditor.putString("latitude", latitude).apply();
                }
                makeApiCall();
            } else if (call.method.equals("getCurrentLocation")) {
                result.success(getLocationFromSharedPreferences());
            }

        });
    }


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        myReceiver = new MyReceiver();
        if (!checkPermissions()) {
            requestPermissions();
        }
    }

    @Override
    protected void onStart() {
        super.onStart();
        PreferenceManager.getDefaultSharedPreferences(this)
                .registerOnSharedPreferenceChangeListener(this);

        // Bind to the service. If the service is in foreground mode, this signals to the service
        // that since this activity is in the foreground, the service can exit foreground mode.
        bindService(new Intent(this, LocationUpdatesService.class), mServiceConnection,
                Context.BIND_AUTO_CREATE);
    }


    @Override
    protected void onResume() {
        super.onResume();
        LocalBroadcastManager.getInstance(this).registerReceiver(myReceiver,
                new IntentFilter(LocationUpdatesService.ACTION_BROADCAST));
    }

    @Override
    protected void onPause() {
        LocalBroadcastManager.getInstance(this).unregisterReceiver(myReceiver);
        super.onPause();
    }

    @Override
    protected void onStop() {
        if (mBound) {
            // Unbind from the service. This signals to the service that this activity is no longer
            // in the foreground, and the service can respond by promoting itself to a foreground
            // service.
            unbindService(mServiceConnection);
            mBound = false;
        }
        PreferenceManager.getDefaultSharedPreferences(this)
                .unregisterOnSharedPreferenceChangeListener(this);
        super.onStop();
    }


    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        Log.i(TAG, "onRequestPermissionResult");
        if (requestCode == REQUEST_PERMISSIONS_REQUEST_CODE) {
            if (grantResults.length <= 0) {
                // If user interaction was interrupted, the permission request is cancelled and you
                // receive empty arrays.
                Log.i(TAG, "User interaction was cancelled.");
            } else if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Permission was granted.
                if (willStartService) {
                    mService.requestLocationUpdates();
                }
            }
        }
    }

    private Map getWaqiDataFromSharedPref() {
        Map<String, String> data = new HashMap<>();
        SharedPreferences sharedPreferences = getSharedPreferences(SharedPreferencesFileName, Context.MODE_PRIVATE);
        data.put("airQualityIndex", sharedPreferences.getString("airQualityIndex", "error"));
        data.put("dateString", sharedPreferences.getString("dateString", "error"));
        data.put("stationAddress", sharedPreferences.getString("stationAddress", "error"));
        data.put("longitude", sharedPreferences.getString("longitude", "error"));
        data.put("latitude", sharedPreferences.getString("latitude", "error"));
        data.put("stationUpdateTime", sharedPreferences.getString("stationUpdateTime", "error"));
        data.put("humidity", sharedPreferences.getString("humidity", "error"));
        data.put("pressure", sharedPreferences.getString("pressure", "error"));
        data.put("temperature", sharedPreferences.getString("temperature", "error"));
        return data;
    }

    private Map getLocationFromSharedPreferences() {
        Map<String, String> data = new HashMap<>();
        SharedPreferences sharedPreferences = getSharedPreferences(SharedPreferencesFileName, Context.MODE_PRIVATE);
        data.put("longitude", sharedPreferences.getString("longitude", "error"));
        data.put("latitude", sharedPreferences.getString("latitude", "error"));
        return data;
    }

    /**
     * Returns the current state of the permissions needed.
     */
    private boolean checkPermissions() {
        return PackageManager.PERMISSION_GRANTED == ActivityCompat.checkSelfPermission(this,
                Manifest.permission.ACCESS_FINE_LOCATION);
    }

    private void requestPermissions() {
        boolean shouldProvideRationale =
                ActivityCompat.shouldShowRequestPermissionRationale(this,
                        Manifest.permission.ACCESS_FINE_LOCATION);

        // Provide an additional rationale to the user. This would happen if the user denied the
        // request previously, but didn't check the "Don't ask again" checkbox.
//        if (shouldProvideRationale) {
//            Log.i(TAG, "Displaying permission rationale to provide additional context.");
//            Snackbar.make(
//                    findViewById(R.id.activity_main),
//                    R.string.permission_rationale,
//                    Snackbar.LENGTH_INDEFINITE)
//                    .setAction(R.string.ok, new View.OnClickListener() {
//                        @Override
//                        public void onClick(View view) {
//                            // Request permission
//                            ActivityCompat.requestPermissions(MainActivity.this,
//                                    new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
//                                    REQUEST_PERMISSIONS_REQUEST_CODE);
//                        }
//                    })
//                    .show();
//        } else {
        Log.i(TAG, "Requesting permission");
        // Request permission. It's possible this can be auto answered if device policy
        // sets the permission in a given state or the user denied the permission
        // previously and checked "Never ask again".
        ActivityCompat.requestPermissions(MainActivity.this,
                new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
                REQUEST_PERMISSIONS_REQUEST_CODE);
//        }
    }

    @Override
    public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String key) {
        Log.d(TAG, "Shared Preferences changed");
    }

    private class MyReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            Location location = intent.getParcelableExtra(LocationUpdatesService.EXTRA_LOCATION);
            if (location != null) {
                Toast.makeText(MainActivity.this, Utils.getLocationText(getApplicationContext(), location),
                        Toast.LENGTH_SHORT).show();
            }
        }
    }


    private void makeApiCall() {
        RetrofitAsyncRequest retrofitAsyncRequest = new RetrofitAsyncRequest(getApplicationContext());
        retrofitAsyncRequest.updateAirQualityIndex();
    }

}
