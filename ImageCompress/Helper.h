//
//  Header.h
//  ImageCompress
//
//  Created by Tenzin Norden on 5/16/23.
//

#ifndef Header_h
#define Header_h


#endif /* Header_h */

- (NSData *)compressImage:(UIImage *)image {
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    compression_stream stream;
    memset(&stream, 0, sizeof(stream));
    stream.src_ptr = imageData.bytes;
    stream.src_size = imageData.length;
    stream.dst_ptr = compressedData.mutableBytes;
    stream.dst_size = compressedData.length;
    stream.dst_capacity = compressedData.length;
    compression_algorithm algorithm = COMPRESSION_LZFSE;
    compression_stream_init(&stream, COMPRESSION_STREAM_ENCODE, algorithm);
    while (stream.src_size > 0) {
        stream.dst_ptr = compressedData.mutableBytes + compressedData.length - stream.dst_size;
        stream.dst_size = compressedData.length - compressedData.length;
        compression_status status = compression_stream_process(&stream, 0);
        if (status != COMPRESSION_STATUS_OK) {
            NSLog(@"Compression failed with status: %ld", status);
            compression_stream_destroy(&stream);
            return nil;
        }
    }
    compression_stream_flush(&stream, COMPRESSION_STREAM_FINALIZE);
    compressedData.length = compressedData.length - stream.dst_size;
    if (compressedData.length >= maxSizeInBytes) {
        NSLog(@"Compression failed: compressed data is still larger than the desired size limit");
        compression_stream_destroy(&stream);
        return nil;
    }
    compression_stream_destroy(&stream);
}
