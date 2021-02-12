package com.example.flutter_air_quality_widget;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String TAG = "MainActivity";
    private static final String CHANNEL = "air.quality.widget";
    private static final String SharedPreferencesFileName = "AirQualityWidgetApp";
    int PERMISSION_ALL = 1;
    String[] PERMISSIONS = {
            android.Manifest.permission.ACCESS_COARSE_LOCATION,
            android.Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_BACKGROUND_LOCATION
    };

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler((call, result) -> {
            if (call.method.equals("getWaqiData")) {
                result.success(getWaqiDataFromSharedPref());
            }
        });
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //permissions needed for SDK 23 up
        if (Build.VERSION.SDK_INT >= 23) {
            if (checkPermission(this, PERMISSIONS)) {
                Log.d(TAG, "Permission already granted.");
                setupLocationListener();
                makeApiCall();
            } else {
                requestPermission();
            }
        }
    }

    private boolean checkPermission(Context context, String... permissions) {
        if (context != null && permissions != null) {
            for (String permission : permissions) {
                if (ActivityCompat.checkSelfPermission(context, permission) != PackageManager.PERMISSION_GRANTED) {
                    return false;
                }
            }
        }
        return true;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        Log.d(TAG, "Called after permission granted");
        setupLocationListener();
        makeApiCall();
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

    private void requestPermission() {
        ActivityCompat.requestPermissions(this, PERMISSIONS, PERMISSION_ALL);
    }

    private void setupLocationListener() {
        Intent gpsServiceIntent = new Intent(getApplicationContext(), GPSService.class);
        startService(gpsServiceIntent);
    }

    private void makeApiCall() {
        RetrofitAsyncRequest retrofitAsyncRequest = new RetrofitAsyncRequest(getApplicationContext());
        retrofitAsyncRequest.updateAirQualityIndex();
    }
}
