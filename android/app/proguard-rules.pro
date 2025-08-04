# Retrofit, OkHttp, Gson
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Flutter classes
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Your app classes (Update package)
-keep class com.task4task.app.** { *; }

# Dio + Okio (if used)
-keep class com.squareup.okhttp3.** { *; }
-keep class com.squareup.okio.** { *; }
-keep class javax.annotation.** { *; }

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }
-dontwarn com.google.firebase.auth.**

# Google Sign-In
-keep class com.google.android.gms.auth.api.signin.** { *; }
-dontwarn com.google.android.gms.auth.api.signin.**

# Google Play Services Common API
-keep class com.google.android.gms.common.api.** { *; }
-dontwarn com.google.android.gms.common.api.**

# Firebase (optional wildcard)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
