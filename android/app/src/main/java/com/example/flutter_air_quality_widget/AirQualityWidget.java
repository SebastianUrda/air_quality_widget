package com.example.flutter_air_quality_widget;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.util.Log;
import android.widget.RemoteViews;

import java.text.DateFormat;
import java.util.Date;

/**
 * Implementation of App Widget functionality.
 */
public class AirQualityWidget extends AppWidgetProvider {

    private static final String TAG = "AirQualityWidget";
    private static final String SharedPreferencesFileName = "AirQualityWidgetApp";

    private void updateAppWidget(Context context,
                                 AppWidgetManager appWidgetManager,
                                 int appWidgetId) {
        String dateStringDefault =
                DateFormat.getTimeInstance(DateFormat.SHORT).format(new Date());
        SharedPreferences sharedPreferences = context.getSharedPreferences(SharedPreferencesFileName, Context.MODE_PRIVATE);
        String airQualityIndex = sharedPreferences.getString("airQualityIndex", "1");
        String dateString = sharedPreferences.getString("dateString", dateStringDefault);

        // Construct the RemoteViews object.
        RemoteViews views = new RemoteViews(context.getPackageName(),
                R.layout.air_quality_widget);
        if (!airQualityIndex.equals("error")) {

            String colour = getColourBasedOnIndex(airQualityIndex);
            views.setTextColor(R.id.air_quality_index, Color.parseColor(colour));
            views.setTextViewText(R.id.air_quality_index,
                    airQualityIndex);
//            views.setTextViewText(R.id.button_update,
//                    dateString);
        }

//        Log.d(TAG, "Setting intent for button");
//        Intent intentUpdate = new Intent(context, AirQualityWidget.class);
//        // The intent action must be an app widget update.
//        intentUpdate.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
//
//        // Include the widget ID to be updated as an intent extra.
//        int[] idArray = new int[]{appWidgetId};
//        intentUpdate.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, idArray);
//
//
//        PendingIntent pendingUpdate = PendingIntent.getBroadcast(context,
//                appWidgetId, intentUpdate, PendingIntent.FLAG_UPDATE_CURRENT);

        // Assign the pending intent to the button onClick handler
//        views.setOnClickPendingIntent(R.id.button_update, pendingUpdate);
        Intent intent = new Intent(context, MainActivity.class);
        // In widget we are not allowing to use intents as usually. We have to use PendingIntent instead of 'startActivity'
        PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, intent, 0);
        // Here the basic operations the remote view can do.
        views.setOnClickPendingIntent(R.id.section_id, pendingIntent);
        // Instruct the widget manager to update the widget.
        appWidgetManager.updateAppWidget(appWidgetId, views);
    }

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager,
                         int[] appWidgetIds) {
        Log.d(TAG, "On Update method was called");
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
        onStartJobIntentService(context);

    }

    @Override
    public void onEnabled(Context context) {
        onStartJobIntentService(context);
    }

    @Override
    public void onDisabled(Context context) {
        // Enter relevant functionality for when the last widget is disabled
    }


    private void onStartJobIntentService(Context context) {
        Intent mIntent = new Intent(context, UpdatingJobIntentService.class);
        UpdatingJobIntentService.enqueueWork(context, mIntent);
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

