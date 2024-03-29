package com.ttuicube.image_overlay;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.media.ExifInterface;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** ImageOverlayPlugin */
public class ImageOverlayPlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "image_overlay");
    channel.setMethodCallHandler(new ImageOverlayPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("overlayImages")) {
      String srcPath = call.argument("src");
      String dstPath = call.argument("dst");
      overlayImages(srcPath, dstPath);
      result.success("Success!");
    } else {
      result.notImplemented();
    }
  }

  void overlayImages(String srcPath, String dstPath) {

    BitmapFactory.Options options = new BitmapFactory.Options();
    options.inMutable = true;

    Bitmap srcBitmap = BitmapFactory.decodeFile(srcPath);
    Bitmap dstBitmap = BitmapFactory.decodeFile(dstPath, options);

    try {
      ExifInterface exif = new ExifInterface(dstPath);

      int orientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, 1);

      switch (orientation) {
        case ExifInterface.ORIENTATION_ROTATE_90:
          dstBitmap = rotate(dstBitmap, 90);
          break;
        case ExifInterface.ORIENTATION_ROTATE_180:
          dstBitmap = rotate(dstBitmap, 180);
          break;
        case ExifInterface.ORIENTATION_ROTATE_270:
          dstBitmap = rotate(dstBitmap, 270);
          break;
      }

    } catch (IOException e) {
      e.printStackTrace();
    }

    float aspect = srcBitmap.getWidth() / (float)srcBitmap.getHeight();
    int width = dstBitmap.getWidth();
    int height = (int)(dstBitmap.getWidth() / aspect);

    srcBitmap = Bitmap.createScaledBitmap(srcBitmap, width, height, true);

    Canvas canvas = new Canvas(dstBitmap);
    canvas.drawBitmap(srcBitmap, 0, dstBitmap.getHeight() - height, null);

    try {
      FileOutputStream fo = new FileOutputStream(dstPath);
      dstBitmap.compress(Bitmap.CompressFormat.JPEG, 90, fo);
      fo.flush();
      fo.close();
      System.out.println("Done!");
    } catch (IOException e) {
      e.printStackTrace();
    }
  }

  private Bitmap rotate(Bitmap src, int degrees) {
    Matrix mat = new Matrix();
    mat.postRotate(degrees);
    return Bitmap.createBitmap(src, 0, 0, src.getWidth(), src.getHeight(), mat, true);
  }
}
