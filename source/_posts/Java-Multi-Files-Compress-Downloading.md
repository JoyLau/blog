---
title: Java 多文件边压缩边下载
date: 2020-07-01 09:42:35
description: Java 多文件边压缩边下载
categories: [Java篇]
tags: [Java]
---
<!-- more -->
有时我们希望在后台实时生成文件并下载到客户端

``` java
    @GetMapping(value = "download")
    public void download(HttpServletResponse response) {
       try(OutputStream outputStream = response.getOutputStream();
          ZipOutputStream zipOutputStream = new ZipOutputStream(outputStream, StandardCharsets.UTF_8)
       ) {
          response.setContentType("application/octet-stream");
          response.setHeader("Content-Disposition", "attachment; filename=" + new String("压缩文件.zip".getBytes("UTF-8"), "ISO-8859-1"));
    
          File[] files = new File("").listFiles();
          for (File file : files) {
             // 单个文件压缩
             compress(zipOutputStream, new FileInputStream(file), file.getName());
          }
          zipOutputStream.flush();
       } catch (IOException e) {
       }
    
    }
    
    
    
    /**
     * 单个文件压缩
     *
     * @param zipOutputStream
     * @param inputStream
     * @param fileName
     * @throws IOException
     */
    private static void compress(ZipOutputStream zipOutputStream, InputStream inputStream, String fileName) throws IOException {
        if (inputStream == null) return;
        zipOutputStream.putNextEntry(new ZipEntry(fileName));
        int bytesRead;
        byte[] buffer = new byte[FileUtil.BUFFER_SIZE];
        while ((bytesRead = inputStream.read(buffer)) != -1) {
            zipOutputStream.write(buffer, 0, bytesRead);
        }
        zipOutputStream.closeEntry();
        inputStream.close();
    }
```