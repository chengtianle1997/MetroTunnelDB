using System;
using System.Collections.Generic;

using libMetroTunnelDB;

namespace MetroTunnelDBApps
{
    class Program
    {
        static float[] x, y;

        static void GenData(MetroTunnelDB db, int RecordID, int TimeStamp)
        {
            Random ro = new Random();
            DataRaw[] dr_arr = new DataRaw[8];
            ImageRaw[] ir_arr = new ImageRaw[8];
            for (int i = 0; i < 8; i++)
            {
                int ts = TimeStamp + ro.Next(0, 50) * (ro.Next() % 2 * 2 - 1);
                dr_arr[i] = new DataRaw(RecordID, ts, i + 1, x, y);
                ir_arr[i] = new ImageRaw(RecordID, ts, i + 1, String.Format("{0}-{1}-{2}.jpg", RecordID, ts, i + 1));
            }
            db.InsertIntoDataRaw(dr_arr);
            db.InsertIntoImageRaw(ir_arr);

            for (int i = 0; i < 2048; i++)
            {
                x[i] += 1;
                y[i] += 1;
            }
        }

        static void DataConverter(DataRaw[] cluster, ref DataConv dataConverted)
        {
            for (int i = 0; i < 8; i++)
            {
                Array.Copy(cluster[i].x, 0, dataConverted.s, 2048 * i, 2048);
                Array.Copy(cluster[i].y, 0, dataConverted.a, 2048 * i, 2048);
            }
        }

        static void initDB(ref MetroTunnelDB db)
        {
            db.InsertIntoLine(new Line("3", "3号线", 234.43F, DateTime.Now));

            db.InsertIntoDetectDevice(new DetectDevice("3-01", "3号线-01", 1, DateTime.Now));

            db.InsertIntoDetectRecord(new DetectRecord(1, new DateTime(2019, 11, 28, 23, 30, 00), "3-01", 300, 23421, 23721));
            db.InsertIntoDetectRecord(new DetectRecord(1, new DateTime(2019, 12, 28, 06, 30, 00), "3-01", 500, 3477, 3977));

            GenData(db, 1, (int)(23.5 * 60 * 60 * 1000));
            GenData(db, 1, (int)(0.5 * 60 * 60 * 1000));
            GenData(db, 2, 23 * 60 * 60 * 1000);
            GenData(db, 2, 22 * 60 * 60 * 1000);

            db.InsertIntoTandD(new TandD(1, 18 * 60 * 60 * 1000, 6));
            db.InsertIntoTandD(new TandD(1, 6 * 60 * 60 * 1000 - 1, 18));
            db.InsertIntoTandD(new TandD(2, 0, 0));
            db.InsertIntoTandD(new TandD(2, 24 * 60 * 60 * 1000 - 1, 24));

            db.InsertIntoDataOverview(new DataOverview(1, 342.34f, 5345f, 534, 124f, 2.45f, false, true));
        }

        static void Main(string[] args)
        {

            MetroTunnelDB db = new MetroTunnelDB(passwd: "lkjhhff1");
            //MetroTunnelDB.DataConverter processData = Program.DataConverter;

            x = new float[2048];
            y = new float[2048];
            for (int i = 1; i <= 2048; i++)
            {
                x[i - 1] = i + 1f / i;
                y[i - 1] = 2048 - i + 1f / i;
            }

            initDB(ref db);
            db.ProcessDetectRecord(1, DataConverter);
            db.ProcessDetectRecord(2, DataConverter);

            Line Line = null;
            db.QueryLine(ref Line, 1);

            DetectDevice DetectDevice = null;
            db.QueryDetectDevice(ref DetectDevice, 1);

            DetectRecord DetectRecord = null;
            db.QueryDetectRecord(ref DetectRecord, 1);

            List<DataOverview> do_arr = new List<DataOverview>();
            db.QueryDataOverview(ref do_arr, 1, 11.2f, 23);

            List<DataRaw> dr_arr = new List<DataRaw>();
            db.QueryDataRaw(ref dr_arr, 1, 1, (int)(0.5 * 60 * 60 * 1000), 22 * 60 * 60 * 1000);
            dr_arr.Clear();
            db.QueryDataRaw(ref dr_arr, 2);

            List<DataConv> dc_arr = new List<DataConv>();
            db.QueryDataConv(ref dc_arr, 1, 2, 11.2f, 23);

            List<ImageRaw> ir_arr = new List<ImageRaw>();
            db.QueryImageRaw(ref ir_arr, 2, (int)(0.5 * 60 * 60 * 1000), 22 * 60 * 60 * 1000);

            List<ImageDisp> id_arr = new List<ImageDisp>();
            db.QueryImageDisp(ref id_arr, 1, 11.2f, 23);


        }
    }
}
