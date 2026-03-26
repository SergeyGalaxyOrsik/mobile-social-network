abstract final class MediaUploadConstants {
  static const int maxFileBytes = 104857600; // 100 MiB
  static const int singlePutMaxBytes = 8388608; // 8 MiB
  static const int minPartBytes = 5242880; // 5 MiB (S3)
  static const int maxMediaPerPost = 10;
}
