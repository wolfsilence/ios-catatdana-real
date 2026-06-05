import Foundation

struct DIStorage: Codable {
    var ram_total_size: String? //  // 运行内存总大小(单位byte)，用ActivityManager.MemoryInfo.totalMem赋值
    var ram_usable_size: String? // 运行内存可用大小(单位byte)，用ActivityManager.MemoryInfo.availMem赋值
    
    /*
         * stat = new StatFs(Environment.getDataDirectory().getPath())
         *   总空间：stat.getBlockCountLong() * stat.getBlockSizeLong()
         *   可用空间：stat.getAvailableBlocksLong() * stat.getBlockSizeLong()
         */
    var internal_storage_usable: String?    // 内部存储可用空间(单位byte)
    var internal_storage_total: String? // 内部存储总空间(单位byte)
    
    
    /*
     * Environment.getExternalStorageState().equals("mounted") 外部存储可用的情况下
     * stat = new StatFs(Environment.getExternalStorageDirectory().getPath());
     * long blockSize = stat.getBlockSizeLong();
     * long totalBlocks = stat.getBlockCountLong();
     * long availableBlocks = stat.getAvailableBlocksLong();
     * 总空间： totalBlocks * blockSize;
     * 可用空间： availableBlocks * blockSize
     * 已用空间： memory_card_size - memory_card_usable_size
     *
     */
    
    var memory_card_size: String? // 外部存储总空间(单位byte)
    var memory_card_size_use: String? //外部存储已用空间(单位byte)

}
