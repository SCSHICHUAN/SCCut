//
//  one_frame.h
//  SCCut
//
//  Created by Stan on 2023/3/7.
//

#ifndef one_frame_h
#define one_frame_h

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>

#define INBUF_SIZE 4096

#define WORD uint16_t
#define DWORD uint32_t
#define LONG int32_t

#define BaseTime 100000

int wellDone;
int  fream_count = 0;


#pragma pack(2)
typedef struct tagBITMAPFILEHEADER {
  WORD  bfType;
  DWORD bfSize;
  WORD  bfReserved1;
  WORD  bfReserved2;
  DWORD bfOffBits;
} BITMAPFILEHEADER, *PBITMAPFILEHEADER;


typedef struct tagBITMAPINFOHEADER {
  DWORD biSize;
  LONG  biWidth;
  LONG  biHeight;
  WORD  biPlanes;
  WORD  biBitCount;
  DWORD biCompression;
  DWORD biSizeImage;
  LONG  biXPelsPerMeter;
  LONG  biYPelsPerMeter;
  DWORD biClrUsed;
  DWORD biClrImportant;
} BITMAPINFOHEADER, *PBITMAPINFOHEADER;

void saveBMP(struct SwsContext *img_convert_ctx, AVFrame *frame, char *filename)
{
    //1 先进行转换,  YUV420=>RGB24:
    int w = frame->width;
    int h = frame->height;


    int numBytes=avpicture_get_size(AV_PIX_FMT_BGR24, w, h);
    uint8_t *buffer=(uint8_t *)av_malloc(numBytes*sizeof(uint8_t));


    AVFrame *pFrameRGB = av_frame_alloc();
     /* buffer is going to be written to rawvideo file, no alignment */
    /*
    if (av_image_alloc(pFrameRGB->data, pFrameRGB->linesize,
                              w, h, AV_PIX_FMT_BGR24, pix_fmt, 1) < 0) {
        fprintf(stderr, "Could not allocate destination image\n");
        exit(1);
    }
    */
    avpicture_fill((AVPicture *)pFrameRGB, buffer, AV_PIX_FMT_BGR24, w, h);

    sws_scale(img_convert_ctx, frame->data, frame->linesize,
              0, h, pFrameRGB->data, pFrameRGB->linesize);

    //2 构造 BITMAPINFOHEADER
    BITMAPINFOHEADER header;
    header.biSize = sizeof(BITMAPINFOHEADER);


    header.biWidth = w;
    header.biHeight = h*(-1);
    header.biBitCount = 24;
    header.biCompression = 0;
    header.biSizeImage = 0;
    header.biClrImportant = 0;
    header.biClrUsed = 0;
    header.biXPelsPerMeter = 0;
    header.biYPelsPerMeter = 0;
    header.biPlanes = 1;

    //3 构造文件头
    BITMAPFILEHEADER bmpFileHeader = {0,};
    //HANDLE hFile = NULL;
//    DWORD dwTotalWriten = 0;
//    DWORD dwWriten;

    bmpFileHeader.bfType = 0x4d42; //'BM';
    bmpFileHeader.bfSize = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER)+ numBytes;
    bmpFileHeader.bfOffBits=sizeof(BITMAPFILEHEADER)+sizeof(BITMAPINFOHEADER);

    FILE* pf = fopen(filename, "wb");
    fwrite(&bmpFileHeader, sizeof(BITMAPFILEHEADER), 1, pf);
    fwrite(&header, sizeof(BITMAPINFOHEADER), 1, pf);
    fwrite(pFrameRGB->data[0], 1, numBytes, pf);
    fclose(pf);


    //释放资源
    //av_free(buffer);
    av_freep(&pFrameRGB[0]);
    av_free(pFrameRGB);
}

static void pgm_save(unsigned char *buf, int wrap, int xsize, int ysize,
                     char *filename)
{
    FILE *f;
    int i;

    f = fopen(filename,"w");
    fprintf(f, "P5\n%d %d\n%d\n", xsize, ysize, 255);
    for (i = 0; i < ysize; i++)
        fwrite(buf + i * wrap, 1, xsize, f);
    fclose(f);
}

static int decode_write_frame(const char *outfilename, AVCodecContext *avctx,
                              struct SwsContext *img_convert_ctx, AVFrame *frame, int *frame_count, AVPacket *pkt, int last,AVStream *st,int64_t start_time,int64_t end_time)
{
    int len, got_frame;
    char buf[1024];

    
    /*
     开始解码
     avctx     : 编解码器环境
     frame     : 输出帧
     got_frame : 是否解码完成一帧
     pkt       : 输入数据
    */
    len = avcodec_decode_video2(avctx, frame, &got_frame, pkt);
    if (len < 0) {
        fprintf(stderr, "Error while decoding frame %d\n", *frame_count);
        return len;
    }
    //如果解码完成一帧
    if (got_frame) {
        
        
        //判断是否大于结束时间 ms
        float pkg_time = av_q2d(st->time_base) * pkt->pts;
        printf("av_pkg_time = %f s\n",pkg_time);
        
        /*
         start_time < pkg_time
         修复100ms到100ms 取多帧bug
        */
//        if (start_time <= pkg_time) {
            
            printf("Saving %sframe %3d\n", last ? "last " : "", *frame_count);
            fflush(stdout);

            /* the picture is allocated by the decoder, no need to free it */
            snprintf(buf, sizeof(buf), "%s-%d.bmp", outfilename, *frame_count);
            
            //转换为RGB保存为bmp
            saveBMP(img_convert_ctx, frame, buf);
            
            (*frame_count)++;
        }
        
        
        
        fream_count = *frame_count;
    
//    }
    return 0;
}

int getOneFreame(int argc,const char **argv)
{
    
    int ret;
    const char *filename, *outfilename;
    int64_t  start_time,end_time,all_time,step_time;
    AVFormatContext *fmt_ctx = NULL;
    const AVCodec *codec;
    AVCodecContext *c= NULL;
    AVStream *st = NULL;
    int stream_index;
    int frame_count;
    AVFrame *frame;
    struct SwsContext *img_convert_ctx;
    //uint8_t inbuf[INBUF_SIZE + AV_INPUT_BUFFER_PADDING_SIZE];
    AVPacket avpkt;

    if (argc <= 4) {
        fprintf(stderr, "Usage: %s <input file> <output file> <start_time ms><end_time ms>\n", argv[0]);
        exit(0);
    }
    
    
    filename    = argv[1];
    outfilename = argv[2];
    start_time  = atoi(argv[3]);
    end_time    = atoi(argv[4]);
    
    
   

    
    av_register_all();

    /*打开输入文件*/
    if (avformat_open_input(&fmt_ctx, filename, NULL, NULL) < 0) {
        fprintf(stderr, "Could not open source file %s\n", filename);
        exit(1);
    }

    /*找到输入文件的信息*/

    if (avformat_find_stream_info(fmt_ctx, NULL) < 0) {
        fprintf(stderr, "Could not find stream information\n");
        exit(1);
    }

    /*打印输入文件的信息*/
    av_dump_format(fmt_ctx, 0, filename, 0);


    fprintf(stderr, "time:%lld \n",(fmt_ctx->duration)/AV_TIME_BASE);
    all_time = (fmt_ctx->duration)/BaseTime;
    
    step_time = all_time/10;
    
    //找到视频流
    ret = av_find_best_stream(fmt_ctx, AVMEDIA_TYPE_VIDEO, -1, -1, NULL, 0);
    if (ret < 0) {
        fprintf(stderr, "Could not find %s stream in input file '%s'\n",
                av_get_media_type_string(AVMEDIA_TYPE_VIDEO), filename);
        return ret;
    }

    stream_index = ret;
    //拿到视频流的实例
    st = fmt_ctx->streams[stream_index];

    /*找到视频流的编解码器*/
    codec = avcodec_find_decoder(st->codecpar->codec_id);
    if (!codec) {
        fprintf(stderr, "Failed to find %s codec\n",
                av_get_media_type_string(AVMEDIA_TYPE_VIDEO));
        return AVERROR(EINVAL);
    }
    
    //分配编解码器上下文
    c = avcodec_alloc_context3(NULL);
    if (!c) {
        fprintf(stderr, "Could not allocate video codec context\n");
        exit(1);
    }

    /*编解码器拷贝到创建的上下文中*/
    if ((ret = avcodec_parameters_to_context(c, st->codecpar)) < 0) {
        fprintf(stderr, "Failed to copy %s codec parameters to decoder context\n",
                av_get_media_type_string(AVMEDIA_TYPE_VIDEO));
        return ret;
    }


    /*打开编解码器环境 */
    if (avcodec_open2(c, codec, NULL) < 0) {
        fprintf(stderr, "Could not open codec\n");
        exit(1);
    }

    //图片视频裁剪 初始化
    img_convert_ctx = sws_getContext(c->width, c->height,
                                     c->pix_fmt,
                                     c->width, c->height,
                                     AV_PIX_FMT_BGR24,
                                     SWS_BICUBIC, NULL, NULL, NULL);

    if (img_convert_ctx == NULL)
    {
        fprintf(stderr, "Cannot initialize the conversion context\n");
        exit(1);
    }

    //初始化frame
    frame = av_frame_alloc();
    if (!frame) {
        fprintf(stderr, "Could not allocate video frame\n");
        exit(1);
    }
    //初始化AVPacket
    av_init_packet(&avpkt);
    /*
     跳到指定的秒数 AVSEEK_FLAG_BACKWARD
     是seek到请求的timestamp之前最近的关键帧
     1000.0 已毫秒计算时间
     AV_TIME_BASE    1000000
     */
    ret = av_seek_frame(fmt_ctx, -1, start_time*BaseTime, AVSEEK_FLAG_BACKWARD);
    if (ret < 0) {
        fprintf(stderr, "Error seek\n");
        exit(1);
    }
    //读取输入上下文的数据
    wellDone = 0;
    frame_count = 1;
    while (av_read_frame(fmt_ctx, &avpkt) >= 0) {
        if (wellDone) {
            break;
        }
        //如果是视频流
        if(avpkt.stream_index == stream_index){
            if (decode_write_frame(outfilename, c, img_convert_ctx, frame, &frame_count, &avpkt, 0,st,start_time,end_time) < 0){
                exit(1);
            }else{
                av_seek_frame(fmt_ctx, -1, start_time*BaseTime, AVSEEK_FLAG_BACKWARD);
                start_time += step_time;
                if(start_time >= all_time){
                    wellDone = 1;
                }
            }
        }
        av_packet_unref(&avpkt);
    }
    avpkt.data = NULL;
    avpkt.size = 0;
 

    

    avformat_close_input(&fmt_ctx);
    sws_freeContext(img_convert_ctx);
    avcodec_free_context(&c);
    av_frame_free(&frame);
    
    printf("start_time = %lld,end_time = %lld\n",start_time,end_time);

    return 0;
}


#endif /* one_frame_h */
