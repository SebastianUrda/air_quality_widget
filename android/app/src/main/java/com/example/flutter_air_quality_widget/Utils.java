package com.example.flutter_air_quality_widget;

import android.content.Context;
import android.content.SharedPreferences;
import android.location.Location;
import android.preference.PreferenceManager;

class Utils {

    static final String KEY_REQUESTING_LOCATION_UPDATES = "requesting_locaction_updates";
    private static final String SharedPreferencesFileName = "AirQualityWidgetApp";

    /**
     * Returns true if requesting location updates, otherwise returns false.
     *
     * @param context The {@link Context}.
     */
    static boolean requestingLocationUpdates(Context context) {
        return PreferenceManager.getDefaultSharedPreferences(context)
                .getBoolean(KEY_REQUESTING_LOCATION_UPDATES, false);
    }

    /**
     * Stores the location updates state in SharedPreferences.
     *
     * @param requestingLocationUpdates The location updates state.
     */
    static void setRequestingLocationUpdates(Context context, boolean requestingLocationUpdates) {
        PreferenceManager.getDefaultSharedPreferences(context)
                .edit()
                .putBoolean(KEY_REQUESTING_LOCATION_UPDATES, requestingLocationUpdates)
                .apply();
    }

    /**
     * Returns the {@code location} object as a human readable string.
     *
     * @param location The {@link Location}.
     */
    static String getLocationText(Context context, Location location) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(SharedPreferencesFileName, Context.MODE_PRIVATE);
        String aqi = sharedPreferences.getString("airQualityIndex", "error");

        String humidity = sharedPreferences.getString("humidity", "error");
        String pressure = sharedPreferences.getString("pressure", "error");

        return location == null ? "Unknown location" :
                "AQI: " + aqi + ", Humidity: " + humidity + "% , Pressure: " + pressure+" mbar";
    }

    static String getLocationTitle(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(SharedPreferencesFileName, Context.MODE_PRIVATE);
        String dateString = sharedPreferences.getString("dateString", "error");
        return context.getString(R.string.location_updated,
                dateString);
    }
}