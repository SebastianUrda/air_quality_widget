package sebi.master.flutter_air_quality;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.text.DateFormat;
import java.util.Date;

import okhttp3.ResponseBody;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

import static android.content.Context.MODE_PRIVATE;

public class RetrofitRequest {
    private static final String TAG = "RetrofitRequest";
    private final String BASE_URL = "https://api.waqi.info/";
    private final String TOKEN = "2af09b666411b6719ba2528edaba5f126f6fdfa3";
    private Retrofit retrofit = new Retrofit.Builder()
            .baseUrl(BASE_URL)
            .addConverterFactory(GsonConverterFactory.create())
            .build();
    Context context;
    private static final String SharedPreferencesFileName = "AirQualityWidgetApp";

    public RetrofitRequest(Context context) {
        this.context = context;
    }

    public void getAirQualityIndex() {
        Log.d(TAG, "Request Made");
        RetrofitAqiService retrofitAqiService = retrofit.create(RetrofitAqiService.class);
        SharedPreferences sharedPreferences = context.getSharedPreferences(SharedPreferencesFileName, MODE_PRIVATE);
        String longitude = sharedPreferences.getString("longitude", "0");
        String latitude = sharedPreferences.getString("latitude", "0");
        Log.d(TAG, latitude + ", " + longitude);
        if (longitude.equals("0") && latitude.equals("0")) {
            try {
                Log.d(TAG, "Request made with IP");
                ResponseBody responseBody = retrofitAqiService.getAqi(TOKEN).execute().body();
                String responseBodyString = responseBody.string();
                Log.d("API Response", responseBodyString);
                JSONObject json = new JSONObject(responseBodyString);
                String airQualityIndex = json.getJSONObject("data").getString("aqi");
                String stationAddress = json.getJSONObject("data").getJSONObject("city").getString("name");
                String stationUpdateTime = json.getJSONObject("data").getJSONObject("time").getString("s");
                String humidity = json.getJSONObject("data").getJSONObject("iaqi").getJSONObject("h").getString("v");
                String pressure = json.getJSONObject("data").getJSONObject("iaqi").getJSONObject("p").getString("v");
                String temperature = json.getJSONObject("data").getJSONObject("iaqi").getJSONObject("t").getString("v");
                String epaUrl = json.getJSONObject("data").getJSONArray("attributions").getJSONObject(0).getString("url");
                String epaName = json.getJSONObject("data").getJSONArray("attributions").getJSONObject(0).getString("name");
                String waqiUrl = json.getJSONObject("data").getJSONArray("attributions").getJSONObject(1).getString("url");
                String waqiName = json.getJSONObject("data").getJSONArray("attributions").getJSONObject(1).getString("name");

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
                sharedPreferencesForAirQualityDataEditor.putString("epa_url", epaUrl);
                sharedPreferencesForAirQualityDataEditor.putString("epa_name", epaName);
                sharedPreferencesForAirQualityDataEditor.putString("waqi_url", waqiUrl);
                sharedPreferencesForAirQualityDataEditor.putString("waqi_name", waqiName);

                sharedPreferencesForAirQualityDataEditor.apply();
            } catch (IOException | JSONException e) {
                Log.d(TAG, e.getMessage());
            }

        } else {
            try {
                Log.d(TAG, "Request made with location");
                String position = latitude + ";" + longitude;
                ResponseBody responseBody = retrofitAqiService.getLocationBasedAqi(position, TOKEN).execute().body();
                String responseBodyString = responseBody.string();
                Log.d("API Response", responseBodyString);
                JSONObject json = new JSONObject(responseBodyString);
                String airQualityIndex = json.getJSONObject("data").getString("aqi");
                String stationAddress = json.getJSONObject("data").getJSONObject("city").getString("name");
                String stationUpdateTime = json.getJSONObject("data").getJSONObject("time").getString("s");
                String humidity = json.getJSONObject("data").getJSONObject("iaqi").getJSONObject("h").getString("v");
                String pressure = json.getJSONObject("data").getJSONObject("iaqi").getJSONObject("p").getString("v");
                String temperature = json.getJSONObject("data").getJSONObject("iaqi").getJSONObject("t").getString("v");
                String epaUrl = json.getJSONObject("data").getJSONArray("attributions").getJSONObject(0).getString("url");
                String epaName = json.getJSONObject("data").getJSONArray("attributions").getJSONObject(0).getString("name");
                String waqiUrl = json.getJSONObject("data").getJSONArray("attributions").getJSONObject(1).getString("url");
                String waqiName = json.getJSONObject("data").getJSONArray("attributions").getJSONObject(1).getString("name");

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
                sharedPreferencesForAirQualityDataEditor.putString("epa_url", epaUrl);
                sharedPreferencesForAirQualityDataEditor.putString("epa_name", epaName);
                sharedPreferencesForAirQualityDataEditor.putString("waqi_url", waqiUrl);
                sharedPreferencesForAirQualityDataEditor.putString("waqi_name", waqiName);
                sharedPreferencesForAirQualityDataEditor.apply();

            } catch (IOException | JSONException e) {
                Log.d(TAG, e.getMessage());
            }
        }


    }

}
