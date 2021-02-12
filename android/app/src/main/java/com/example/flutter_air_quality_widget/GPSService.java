package com.example.flutter_air_quality_widget;

import android.annotation.SuppressLint;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;

public class GPSService extends Service implements LocationListener {
    private static final String TAG = "GPSService";
//    private LocationListener listener;
    private LocationManager locationManager;
    private static final String SharedPreferencesFileName = "AirQualityWidgetApp";
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @SuppressLint("MissingPermission")
    @Override
    public void onCreate() {
        Log.d(TAG, "GPSService is working");
        locationManager = (LocationManager) getApplicationContext().getSystemService(Context.LOCATION_SERVICE);
        locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 60000, 0, this);

    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (locationManager != null) {
            locationManager.removeUpdates(this);
        }
    }

    private void makeApiCall() {
        RetrofitAsyncRequest retrofitAsyncRequest = new RetrofitAsyncRequest(getApplicationContext());
        retrofitAsyncRequest.updateAirQualityIndex();
    }

    @Override
    public void onLocationChanged(Location location) {
        SharedPreferences.Editor sharedPreferencesEditor = getSharedPreferences(SharedPreferencesFileName, MODE_PRIVATE).edit();
        sharedPreferencesEditor.putString("longitude", String.valueOf(location.getLongitude())).apply();
        sharedPreferencesEditor.putString("latitude", String.valueOf(location.getLatitude())).apply();
        Log.d(TAG, "GPS Updated");
        makeApiCall();
    }

    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) {

    }

    @Override
    public void onProviderEnabled(String provider) {

    }

    @Override
    public void onProviderDisabled(String provider) {

    }
}