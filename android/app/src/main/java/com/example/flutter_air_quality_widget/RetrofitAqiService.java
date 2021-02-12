package com.example.flutter_air_quality_widget;

import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.http.GET;
import retrofit2.http.Path;
import retrofit2.http.Query;

public interface RetrofitAqiService {
    @GET("/feed/here/")
    Call<ResponseBody> getAqi(@Query("token") String userToken);
//    "https://api.waqi.info/feed/geo:" + latitude + ";" + longitude + "/?token=2af09b666411b6719ba2528edaba5f126f6fdfa3"
    @GET("/feed/geo:{position}/")
    Call<ResponseBody> getLocationBasedAqi(@Path("position") String position, @Query("token") String userToken);
}
