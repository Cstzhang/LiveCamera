#include <jni.h>
#include <string>
#include "FFDemux.h"
#include "IPlayProxy.h"
#include <android/native_window_jni.h>

extern "C"
JNIEXPORT
jint JNI_OnLoad(JavaVM *vm, void *res) {

    IPlayProxy::Get()->Init(vm);
    return JNI_VERSION_1_4;

}



extern "C"
JNIEXPORT void JNICALL
Java_com_cvte_afsyb_jingzi_mvp_ui_activity_XPlay_InitView(JNIEnv *env, jobject instance,
                                                          jobject surface) {

    ANativeWindow *win = ANativeWindow_fromSurface(env, surface);
    IPlayProxy::Get()->InitView(win);

}

extern "C"
JNIEXPORT void JNICALL
Java_com_cvte_afsyb_jingzi_mvp_ui_activity_OpenUrlActivity_Open(JNIEnv *env, jobject instance,
                                                                jstring url_) {
    const char *url = env->GetStringUTFChars(url_, 0);

    IPlayProxy::Get()->Open(url);
    IPlayProxy::Get()->Start();

    env->ReleaseStringUTFChars(url_, url);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_cvte_afsyb_jingzi_jniFun_PlayControl_open(JNIEnv *env, jobject instance, jstring url_) {
    const char *url = env->GetStringUTFChars(url_, 0);

    IPlayProxy::Get()->Open(url);
    IPlayProxy::Get()->Start();

    env->ReleaseStringUTFChars(url_, url);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_cvte_afsyb_jingzi_jniFun_PlayControl_startPushStream(JNIEnv *env, jobject instance,
                                                              jstring url_, jboolean isPushToRTMP) {
    const char *url = env->GetStringUTFChars(url_, 0);

    IPlayProxy::Get()->StartPushStream(url, isPushToRTMP);

    env->ReleaseStringUTFChars(url_, url);

    env->ReleaseStringUTFChars(url_, url);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_cvte_afsyb_jingzi_jniFun_PlayControl_stopPushStream(JNIEnv *env, jobject instance) {

    IPlayProxy::Get()->StopPushStream();

}

extern "C"
JNIEXPORT void JNICALL
Java_com_cvte_afsyb_jingzi_jniFun_PlayControl_destroy(JNIEnv *env, jobject instance) {

    // TODO
    IPlayProxy::Get()->Destroy();

}

extern "C"
JNIEXPORT void JNICALL
Java_com_cvte_afsyb_jingzi_jniFun_PlayControl_setVertexSize(JNIEnv *env, jobject instance,
                                                            jfloat widthRatioForScreen,
                                                            jfloat heightRationForScreen,
                                                            jfloat screenRatio) {

    // set XShader VertexAttriArray
    IPlayProxy::Get()->SetShaderVertex(widthRatioForScreen, heightRationForScreen, screenRatio);

}