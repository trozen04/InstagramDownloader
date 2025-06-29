# Preserve all Castar SDK classes
-keep class com.castar.** { *; }

# Keep any annotations (in case the SDK uses reflection)
-keepclassmembers class * {
    @com.castar.** *;
}
-keepattributes *Annotation*, Signature

# If SDK uses JNI (native libs)
-keepclasseswithmembernames class * {
    native <methods>;
}

# Prevent removal of Activity lifecycle methods
-keepclassmembers class * extends android.app.Activity {
   public void *(...);
}
