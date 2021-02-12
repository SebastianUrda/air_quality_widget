package com.example.flutter_air_quality_widget;

import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.util.Log;
import android.widget.RemoteViews;

import androidx.annotation.NonNull;
import androidx.core.app.JobIntentService;

import java.text.DateFormat;
import java.util.Date;

public class UpdatingJobIntentService extends JobIntentService {
    private static final String TAG = "UJIS";
    private static final String SharedPreferencesFileName = "AirQualityWidgetApp";
    /**
     * Unique job ID for this service.
     */
    private static final int JOB_ID = 1203;

    public static void enqueueWork(Context context, Intent intent) {
        Log.d(TAG, "I was called to enqueue the job");
        enqueueWork(context, UpdatingJobIntentService.class, JOB_ID, intent);
    }

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(TAG, "Job Execution Started");
    }

    @Override
    protected void onHandleWork(@NonNull Intent intent) {
        // Construct the RemoteViews object.
        Log.d(TAG, "I will set it to Shared Preferences");
        RetrofitRequest retrofitRequest = new RetrofitRequest(getApplicationContext());
        retrofitRequest.getAirQualityIndex();

    }


    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "Job Execution Finished");
        String dateStringDefault =
                DateFormat.getTimeInstance(DateFormat.SHORT).format(new Date());
        SharedPreferences sharedPreferences = getSharedPreferences(SharedPreferencesFileName, Context.MODE_PRIVATE);
        String airQualityIndex = sharedPreferences.getString("airQualityIndex", "error");
        if (!airQualityIndex.equals("error") && !airQualityIndex.isEmpty()) {
            RemoteViews views = new RemoteViews(getPackageName(),
                    R.layout.air_quality_widget);
            String colour = getColourBasedOnIndex(airQualityIndex);
            views.setTextColor(R.id.air_quality_index, Color.parseColor(colour));
            views.setTextViewText(R.id.air_quality_index,
                    airQualityIndex);
            ComponentName theWidget = new ComponentName(this, AirQualityWidget.class);
            AppWidgetManager manager = AppWidgetManager.getInstance(this);
            manager.updateAppWidget(theWidget, views);
            Log.d(TAG, "All set");
        }
    }

    private static String getColourBasedOnIndex(String indexString) {
        String GOOD = "#009966";
        String MODERATE = "#FFDE33";
        String UNHEALTHY_SENSITIVE = "#FF9933";
        String UNHEALTHY = "#CC0033";
        String VERY_UNHEALTHY = "#660099";
        String HAZARDOUS = "#7E0023";
        int index = Integer.parseInt(indexString);
        if (index <= 50) return GOOD;
        else if (index <= 100) return MODERATE;
        else if (index <= 150) return UNHEALTHY_SENSITIVE;
        else if (index <= 200) return UNHEALTHY;
        else if (index <= 250) return VERY_UNHEALTHY;
        else return HAZARDOUS;
    }

}
