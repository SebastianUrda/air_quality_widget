package sebi.master.flutter_air_quality;

import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.util.Log;
import android.widget.RemoteViews;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.text.DateFormat;
import java.util.Date;

import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

import static android.content.Context.MODE_PRIVATE;

public class RetrofitAsyncRequest {
    private static final String TAG = "RetrofitAsyncRequest";
    Context context;
    private static final String BASE_URL = "https://api.waqi.info/";
    private static final String TOKEN = "2af09b666411b6719ba2528edaba5f126f6fdfa3";
    private static Retrofit retrofit = new Retrofit.Builder()
            .baseUrl(BASE_URL)
            .addConverterFactory(GsonConverterFactory.create())
            .build();
    private static final String SharedPreferencesFileName = "AirQualityWidgetApp";

    public RetrofitAsyncRequest(Context context) {
        this.context = context;
    }

    public void updateAirQualityIndex() {
        Log.d(TAG, "Request Made");
        RetrofitAqiService retrofitAqiService = retrofit.create(RetrofitAqiService.class);
        SharedPreferences sharedPreferences = context.getSharedPreferences(SharedPreferencesFileName, MODE_PRIVATE);
        String longitude = sharedPreferences.getString("longitude", "0");
        String latitude = sharedPreferences.getString("latitude", "0");
        Log.d(TAG, latitude + ", " + longitude);
        if (longitude.equals("0") && latitude.equals("0")) {
            Log.d(TAG, "Request made with IP");
            retrofitAqiService.getAqi(TOKEN).enqueue(new Callback<ResponseBody>() {
                @Override
                public void onResponse(Call<ResponseBody> call, Response<ResponseBody> response) {
                    try {
                        String responseBodyString = response.body().string();
                        Log.d("API Response Async", responseBodyString);
                        JSONObject json = new JSONObject(responseBodyString);
                        String airQualityIndex = json.getJSONObject("data").getString("aqi");
                        String stationAddress = json.getJSONObject("data").getJSONObject("city").getString("name");
                        String stationUpdateTime = json.getJSONObject("data").getJSONObject("time").getString("s");
                        String humidity = json.getJSONObject("data").getJSONObject("iaqi").getJSONObject("h").getString("v");
                        String pressure = json.getJSONObject("data").getJSONObject("iaqi").getJSONObject("p").getString("v");
                        String temperature = json.getJSONObject("data").getJSONObject("iaqi").getJSONObject("t").getString("v");

                        String dateString =
                                DateFormat.getTimeInstance(DateFormat.SHORT).format(new Date());
                        SharedPreferences.Editor sharedPreferencesForAirQualityDataEditor = context.getSharedPreferences(SharedPreferencesFileName, MODE_PRIVATE).edit();
                        sharedPreferencesForAirQualityDataEditor.putString("airQualityIndex", airQualityIndex);
                        sharedPreferencesForAirQualityDataEditor.putString("dateString", dateString);
                        sharedPreferencesForAirQualityDataEditor.putString("stationAddress", stationAddress);
                        sharedPreferencesForAirQualityDataEditor.putString("stationUpdateTime", stationUpdateTime);
                        sharedPreferencesForAirQualityDataEditor.putString("humidity", humidity);
                        sharedPreferencesForAirQualityDataEditor.putString("pressure", pressure);
                        sharedPreferencesForAirQualityDataEditor.putString("temperature", temperature);
                        sharedPreferencesForAirQualityDataEditor.apply();
                        RemoteViews views = new RemoteViews(context.getPackageName(),
                                R.layout.air_quality_widget);
                        String colour = getColourBasedOnIndex(airQualityIndex);
                        views.setTextColor(R.id.air_quality_index, Color.parseColor(colour));
                        views.setTextViewText(R.id.air_quality_index,
                                airQualityIndex);
                        ComponentName theWidget = new ComponentName(context, AirQualityWidget.class);
                        AppWidgetManager manager = AppWidgetManager.getInstance(context);
                        manager.updateAppWidget(theWidget, views);
                    } catch (IOException | JSONException e) {
                        Log.d(TAG, e.getMessage());
                    }
                }

                @Override
                public void onFailure(Call<ResponseBody> call, Throwable t) {
                    Log.d(TAG, t.getMessage());
                }
            });
        } else {
            Log.d(TAG, "Request made with location");
            String position = latitude + ";" + longitude;
            retrofitAqiService.getLocationBasedAqi(position, TOKEN).enqueue(new Callback<ResponseBody>() {
                @Override
                public void onResponse(Call<ResponseBody> call, Response<ResponseBody> response) {
                    try {
                        String responseBodyString = response.body().string();
                        Log.d("API Response Async", responseBodyString);
                        JSONObject json = new JSONObject(responseBodyString);
                        String airQualityIndex = json.getJSONObject("data").getString("aqi");
                        String stationAddress = json.getJSONObject("data").getJSONObject("city").getString("name");
                        String stationUpdateTime = json.getJSONObject("data").getJSONObject("time").getString("s");
                        String humidity = json.getJSONObject("data").getJSONObject("iaqi").getJSONObject("h").getString("v");
                        String pressure = json.getJSONObject("data").getJSONObject("iaqi").getJSONObject("p").getString("v");
                        String temperature = json.getJSONObject("data").getJSONObject("iaqi").getJSONObject("t").getString("v");

                        String dateString =
                                DateFormat.getTimeInstance(DateFormat.SHORT).format(new Date());
                        SharedPreferences.Editor sharedPreferencesForAirQualityDataEditor = context.getSharedPreferences(SharedPreferencesFileName, MODE_PRIVATE).edit();
                        sharedPreferencesForAirQualityDataEditor.putString("airQualityIndex", airQualityIndex);
                        sharedPreferencesForAirQualityDataEditor.putString("dateString", dateString);
                        sharedPreferencesForAirQualityDataEditor.putString("stationAddress", stationAddress);
                        sharedPreferencesForAirQualityDataEditor.putString("stationUpdateTime", stationUpdateTime);
                        sharedPreferencesForAirQualityDataEditor.putString("humidity", humidity);
                        sharedPreferencesForAirQualityDataEditor.putString("pressure", pressure);
                        sharedPreferencesForAirQualityDataEditor.putString("temperature", temperature);
                        sharedPreferencesForAirQualityDataEditor.apply();
                        RemoteViews views = new RemoteViews(context.getPackageName(),
                                R.layout.air_quality_widget);
                        String colour = getColourBasedOnIndex(airQualityIndex);
                        views.setTextColor(R.id.air_quality_index, Color.parseColor(colour));
                        views.setTextViewText(R.id.air_quality_index,
                                airQualityIndex);
                        ComponentName theWidget = new ComponentName(context, AirQualityWidget.class);
                        AppWidgetManager manager = AppWidgetManager.getInstance(context);
                        manager.updateAppWidget(theWidget, views);
                    } catch (IOException | JSONException e) {
                        Log.d(TAG, e.getMessage());
                    }
                }

                @Override
                public void onFailure(Call<ResponseBody> call, Throwable t) {
                    Log.d(TAG, t.getMessage());
                }
            });
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
