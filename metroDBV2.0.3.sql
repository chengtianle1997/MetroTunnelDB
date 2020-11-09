CREATE DATABASE MetroDB;

USE MetroDB;

CREATE TABLE Line(
    LineID INT NOT NULL AUTO_INCREMENT COMMENT '主键ID，自增',
    LineNumber NVARCHAR(255) NOT NULL COMMENT '轨交线路编号',
    LineName NVARCHAR(255) NOT NULL COMMENT '轨交线路名称',
    TotalMileage FLOAT DEFAULT 0 COMMENT '总里程',
    CreateTime DATETIME NOT NULL COMMENT '线路建设时间',
    IsValid BOOL NOT NULL DEFAULT TRUE COMMENT '是否有效',
    PRIMARY KEY (LineID)
) COMMENT='轨交线路表：存储轨交线路的基本信息';

CREATE TABLE DetectDevice(
    DetectDeviceID INT NOT NULL AUTO_INCREMENT COMMENT '主键ID，自增',
    DetectDeviceNumber NVARCHAR(255) NOT NULL COMMENT '检测设备编号',
    DetectDeviceName NVARCHAR(255) NOT NULL COMMENT '检测设备名称',
    LineID INT COMMENT '外键，关联Line表的主键',
    CreateTime DATETIME NOT NULL COMMENT '记录创建时间',
    IsValid BOOL NOT NULL DEFAULT TRUE COMMENT '是否有效',
    PRIMARY KEY (DetectDeviceID)
    -- FOREIGN KEY (LineID) REFERENCES Line(LineID)
) COMMENT='检测设备表：存储检测设备的基本信息，通过LineID和轨交线路表进行关联';

CREATE TABLE DetectRecord(
    RecordID INT NOT NULL AUTO_INCREMENT COMMENT '主键ID，自增',
    LineID INT NOT NULL COMMENT '外键，线路编号',
    DetectTime DATETIME NOT NULL,
    DeviceID TEXT NOT NULL COMMENT '设备编号',
    Length FLOAT NOT NULL COMMENT '检测长度(m)',
    Start_Loc FLOAT NOT NULL COMMENT '起始位置(m)',
    Stop_Loc FLOAT NOT NULL COMMENT '停止位置(m)',
    PRIMARY KEY (RecordID),
    -- FOREIGN KEY (LineID) REFERENCES Line(LineID),
    CONSTRAINT DetectRecord_Chk_Length CHECK(Length>=0 AND Length=Stop_Loc-Start_Loc)
) COMMENT='检测记录表：记录每次检测的时间、设备和其他概况信息';

CREATE TABLE DataOverview(
    RecordID INT NOT NULL COMMENT '外键，记录编号',
    Distance DOUBLE NOT NULL COMMENT '里程位置(m)',
    LongAxis FLOAT NOT NULL COMMENT '长轴(mm)',
    ShortAxis FLOAT NOT NULL COMMENT '短轴(mm)',
    HorizontalAxis FLOAT NOT NULL COMMENT '水平轴(mm)',
    Rotation FLOAT NOT NULL COMMENT '旋转角(度)',
    Constriction BOOL NOT NULL COMMENT '是否收敛',
    Crack BOOL NOT NULL COMMENT '是否存在裂缝',
    PRIMARY KEY (RecordID, Distance),
    FOREIGN KEY (RecordID) REFERENCES DetectRecord(RecordID),
    CONSTRAINT DataOverview_Chk_LongAxis_NonNegative CHECK(LongAxis>=0),
    CONSTRAINT DataOverview_Chk_ShortAxis_NonNegative CHECK(ShortAxis>=0),
    CONSTRAINT DataOverview_Chk_HorizontalAxis_NonNegative CHECK(HorizontalAxis>=0)
) COMMENT='数据预览表：通过recordid和distance定位环形截面，预览每次记录中不同里程位置的环形概况信息';

CREATE TABLE DataRaw(
    RecordID INT NOT NULL COMMENT '外键，记录编号',
    TimeStamp INT NOT NULL,
    CameraID INT NOT NULL COMMENT '相机编号',
    x BLOB NOT NULL,
    y BLOB NOT NULL,
    PRIMARY KEY (RecordID, TimeStamp, CameraID),
    FOREIGN KEY (RecordID) REFERENCES DetectRecord(RecordID),
    CONSTRAINT DataRaw_Chk_CameraID_Range CHECK(CameraID>=1 AND CameraID<=8),
    CONSTRAINT DataRaw_Chk_TimeStamp_Range CHECK(TimeStamp>=0 AND TimeStamp<=86400000)
) COMMENT='原始数据表：以(RecordID,TimeStamp,CameraID)为主键 每条记录对应 (x,y)*2048组';

CREATE TABLE DataConv(
    RecordID INT NOT NULL COMMENT '外键，记录编号',
    Distance DOUBLE NOT NULL COMMENT '里程位置(m)',
    s MEDIUMBLOB NOT NULL,
    a MEDIUMBLOB NOT NULL,
    PRIMARY KEY (RecordID, Distance),
    FOREIGN KEY (RecordID) REFERENCES DetectRecord(RecordID)
) COMMENT='转换数据表：以(recordid,distance)为主键 每条记录对应(s,a)*2048*8/8组';

CREATE TABLE DataDisp(
    RecordID INT NOT NULL COMMENT '外键，记录编号',
    Distance DOUBLE NOT NULL COMMENT '里程位置(m)',
    JsonString MEDIUMTEXT NOT NULL COMMENT '转发字符串',
    PRIMARY KEY (RecordID, Distance),
    FOREIGN KEY (RecordID) REFERENCES DetectRecord(RecordID)
) COMMENT='呈现数据表：以recordid和distance为索引搜索呈现数据字符串，直接转发';

CREATE TABLE TandD(
    RecordID INT NOT NULL COMMENT '外键，记录编号',
    TimeStamp INT NOT NULL,
    Distance DOUBLE NOT NULL COMMENT '里程位置(m)',
    PRIMARY KEY (RecordID, TimeStamp),
    FOREIGN KEY (RecordID) REFERENCES DetectRecord(RecordID),
    CONSTRAINT TandD_Chk_TimeStamp_Range CHECK(TimeStamp>=0 AND TimeStamp<=86400000)
) COMMENT='VO时间-里程对应表';

CREATE TABLE ImageRaw(
    RecordID INT NOT NULL COMMENT '外键，记录编号',
    TimeStamp INT NOT NULL,
    CameraID INT NOT NULL COMMENT '相机编号',
    FileUrl TEXT NOT NULL,
    PRIMARY KEY (RecordID, TimeStamp, CameraID),
    FOREIGN KEY (RecordID) REFERENCES DetectRecord(RecordID),
    CONSTRAINT ImageRaw_Chk_CameraID_Range CHECK(CameraID>=1 AND CameraID<=8),
    CONSTRAINT ImageRaw_Chk_TimeStamp_Range CHECK(TimeStamp>=0 AND TimeStamp<=86400000)
) COMMENT='红外图像文件表 以(RecordID, TimeStamp, CameraID)为主键';

CREATE TABLE ImageDisp(
    RecordID INT NOT NULL COMMENT '外键，记录编号',
    Distance DOUBLE NOT NULL COMMENT '里程位置(m)',
    FileUrlCam1 TEXT NOT NULL COMMENT '图片文件地址',
    FileUrlCam2 TEXT NOT NULL COMMENT '图片文件地址',
    FileUrlCam3 TEXT NOT NULL COMMENT '图片文件地址',
    FileUrlCam4 TEXT NOT NULL COMMENT '图片文件地址',
    FileUrlCam5 TEXT NOT NULL COMMENT '图片文件地址',
    FileUrlCam6 TEXT NOT NULL COMMENT '图片文件地址',
    FileUrlCam7 TEXT NOT NULL COMMENT '图片文件地址',
    FileUrlCam8 TEXT NOT NULL COMMENT '图片文件地址',
    PRIMARY KEY (RecordID, Distance),
    FOREIGN KEY (RecordID) REFERENCES DetectRecord(RecordID)
) COMMENT='红外图像呈现表：以recordid、distance为索引搜索此位置所有图像文件地址';