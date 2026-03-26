class InitUploadDto {
  const InitUploadDto({required this.contentType, required this.fileSizeBytes});

  final String contentType;
  final int fileSizeBytes;

  Map<String, dynamic> toJson() => {
    'contentType': contentType,
    'fileSizeBytes': fileSizeBytes,
  };
}

enum UploadStrategy { single, multipart }

class InitUploadResponseDto {
  const InitUploadResponseDto({
    required this.strategy,
    required this.mediaId,
    required this.objectKey,
    this.uploadUrl,
    this.expiresInSeconds,
    this.uploadId,
    this.partSizeBytes,
    this.partCount,
  });

  final UploadStrategy strategy;
  final String mediaId;
  final String objectKey;
  final String? uploadUrl;
  final int? expiresInSeconds;
  final String? uploadId;
  final int? partSizeBytes;
  final int? partCount;

  factory InitUploadResponseDto.fromJson(Map<String, dynamic> json) {
    final s = json['strategy'] as String?;
    final strategy = s == 'multipart'
        ? UploadStrategy.multipart
        : UploadStrategy.single;
    return InitUploadResponseDto(
      strategy: strategy,
      mediaId: json['mediaId'] as String,
      objectKey: json['objectKey'] as String,
      uploadUrl: json['uploadUrl'] as String?,
      expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt(),
      uploadId: json['uploadId'] as String?,
      partSizeBytes: (json['partSizeBytes'] as num?)?.toInt(),
      partCount: (json['partCount'] as num?)?.toInt(),
    );
  }
}

class PartPresignResponseDto {
  const PartPresignResponseDto({
    required this.uploadUrl,
    required this.expiresInSeconds,
  });

  final String uploadUrl;
  final int expiresInSeconds;

  factory PartPresignResponseDto.fromJson(Map<String, dynamic> json) {
    return PartPresignResponseDto(
      uploadUrl: json['uploadUrl'] as String,
      expiresInSeconds: (json['expiresInSeconds'] as num).toInt(),
    );
  }
}

class MultipartPartDto {
  const MultipartPartDto({required this.partNumber, required this.etag});

  final int partNumber;
  final String etag;

  Map<String, dynamic> toJson() => {'partNumber': partNumber, 'etag': etag};
}

class CompleteUploadDto {
  const CompleteUploadDto({this.parts});

  final List<MultipartPartDto>? parts;

  Map<String, dynamic> toJson() {
    if (parts == null || parts!.isEmpty) {
      return <String, dynamic>{};
    }
    return {'parts': parts!.map((e) => e.toJson()).toList()};
  }
}
