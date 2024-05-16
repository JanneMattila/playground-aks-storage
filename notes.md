# Notes

Perf testing is always tricky. Here are some
numbers with *very* **very** limited testing.
Your mileage *will* vary.

## Azure NetApp Files NFSv4.1

Using `Premium` with `1TB` ([Service Levels](https://docs.microsoft.com/en-us/azure/azure-netapp-files/azure-netapp-files-service-levels)):

| The Premium storage tier provides up to 64 MiB/s of throughput per 1 TiB of capacity provisioned.

```bash
/mnt/netapp-nfs # fio --directory=perf-test --direct=1 --rw=randwrite --bs=4k --ioengine=libaio --iodepth=256 --runtime=20 --numjobs=4 --time_based --group_reporting --size=4m --name=iops-test-job --eta-newline=1
iops-test-job: (g=0): rw=randwrite, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=256
...
fio-3.27
Starting 4 processes
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
Jobs: 4 (f=4): [w(4)][19.0%][w=51.8MiB/s][w=13.3k IOPS][eta 00m:17s]
Jobs: 4 (f=4): [w(4)][28.6%][w=50.8MiB/s][w=13.0k IOPS][eta 00m:15s] 
Jobs: 4 (f=4): [w(4)][38.1%][w=50.8MiB/s][w=13.0k IOPS][eta 00m:13s] 
Jobs: 4 (f=4): [w(4)][42.9%][w=51.5MiB/s][w=13.2k IOPS][eta 00m:12s]
Jobs: 4 (f=4): [w(4)][47.6%][w=49.5MiB/s][w=12.7k IOPS][eta 00m:11s]
Jobs: 4 (f=4): [w(4)][55.0%][w=54.4MiB/s][w=13.9k IOPS][eta 00m:09s]
Jobs: 4 (f=4): [w(4)][60.0%][w=49.1MiB/s][w=12.6k IOPS][eta 00m:08s]
Jobs: 4 (f=4): [w(4)][70.0%][w=50.1MiB/s][w=12.8k IOPS][eta 00m:06s] 
Jobs: 4 (f=4): [w(4)][80.0%][w=53.4MiB/s][w=13.7k IOPS][eta 00m:04s] 
Jobs: 4 (f=4): [w(4)][90.0%][w=50.5MiB/s][w=12.9k IOPS][eta 00m:02s] 
Jobs: 4 (f=4): [w(4)][100.0%][w=54.1MiB/s][w=13.8k IOPS][eta 00m:00s]
iops-test-job: (groupid=0, jobs=4): err= 0: pid=45: Fri Nov 26 11:37:29 2021
  write: IOPS=13.1k, BW=51.1MiB/s (53.6MB/s)(1027MiB/20098msec); 0 zone resets
    slat (nsec): min=2000, max=99917k, avg=12658.57, stdev=702532.94
    clat (usec): min=1543, max=199980, avg=78144.05, stdev=40461.94
     lat (usec): min=1547, max=199989, avg=78156.92, stdev=40458.13
    clat percentiles (msec):
     |  1.00th=[    3],  5.00th=[    3], 10.00th=[    4], 20.00th=[    9],
     | 30.00th=[   96], 40.00th=[   99], 50.00th=[  100], 60.00th=[  100],
     | 70.00th=[  100], 80.00th=[  100], 90.00th=[  101], 95.00th=[  101],
     | 99.00th=[  105], 99.50th=[  197], 99.90th=[  199], 99.95th=[  201],
     | 99.99th=[  201]
   bw (  KiB/s): min=39856, max=59440, per=100.00%, avg=52440.08, stdev=1015.61, samples=156
   iops        : min= 9963, max=14860, avg=13109.90, stdev=253.97, samples=156
  lat (msec)   : 2=0.26%, 4=10.58%, 10=10.76%, 20=0.95%, 100=71.57%
  lat (msec)   : 250=5.88%
  cpu          : usr=1.00%, sys=2.57%, ctx=29856, majf=0, minf=42
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=99.9%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.1%
     issued rwts: total=0,263009,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=256

Run status group 0 (all jobs):
  WRITE: bw=51.1MiB/s (53.6MB/s), 51.1MiB/s-51.1MiB/s (53.6MB/s-53.6MB/s), io=1027MiB (1077MB), run=20098-20098msec
/mnt/netapp-nfs # 
```

```bash
/mnt/netapp-nfs # fio --directory=perf-test --direct=1 --rw=randread --bs=4k --ioengine=libaio --iodepth=256 --runtime=20 --numjobs=4 --time_based --group_reporting --size=4m --name=iops-test-job --eta-newline=1 --readonly
iops-test-job: (g=0): rw=randread, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=256
...
fio-3.27
Starting 4 processes
Jobs: 4 (f=4): [r(4)][19.0%][r=50.0MiB/s][r=12.8k IOPS][eta 00m:17s]
Jobs: 4 (f=4): [r(4)][28.6%][r=54.2MiB/s][r=13.9k IOPS][eta 00m:15s] 
Jobs: 4 (f=4): [r(4)][33.3%][r=53.5MiB/s][r=13.7k IOPS][eta 00m:14s]
Jobs: 4 (f=4): [r(4)][38.1%][r=48.8MiB/s][r=12.5k IOPS][eta 00m:13s]
Jobs: 4 (f=4): [r(4)][45.0%][r=51.0MiB/s][r=13.1k IOPS][eta 00m:11s]
Jobs: 4 (f=4): [r(4)][55.0%][r=51.6MiB/s][r=13.2k IOPS][eta 00m:09s] 
Jobs: 4 (f=4): [r(4)][60.0%][r=53.6MiB/s][r=13.7k IOPS][eta 00m:08s]
Jobs: 4 (f=4): [r(4)][65.0%][r=52.2MiB/s][r=13.4k IOPS][eta 00m:07s]
Jobs: 4 (f=4): [r(4)][75.0%][r=51.5MiB/s][r=13.2k IOPS][eta 00m:05s] 
Jobs: 4 (f=4): [r(4)][85.0%][r=51.7MiB/s][r=13.2k IOPS][eta 00m:03s] 
Jobs: 4 (f=4): [r(4)][95.0%][r=47.0MiB/s][r=12.0k IOPS][eta 00m:01s] 
Jobs: 4 (f=4): [r(4)][100.0%][r=55.0MiB/s][r=14.1k IOPS][eta 00m:00s]
iops-test-job: (groupid=0, jobs=4): err= 0: pid=56: Fri Nov 26 11:38:16 2021
  read: IOPS=13.4k, BW=52.2MiB/s (54.7MB/s)(1044MiB/20013msec)
    slat (nsec): min=1500, max=100129k, avg=12433.76, stdev=728511.45
    clat (usec): min=1319, max=199459, avg=76643.29, stdev=41696.06
     lat (usec): min=1324, max=199465, avg=76655.92, stdev=41692.46
    clat percentiles (usec):
     |  1.00th=[  1991],  5.00th=[  2376], 10.00th=[  3458], 20.00th=[  6587],
     | 30.00th=[ 94897], 40.00th=[ 98042], 50.00th=[ 99091], 60.00th=[ 99091],
     | 70.00th=[ 99091], 80.00th=[ 99091], 90.00th=[100140], 95.00th=[100140],
     | 99.00th=[102237], 99.50th=[198181], 99.90th=[200279], 99.95th=[200279],
     | 99.99th=[200279]
   bw (  KiB/s): min=41524, max=59024, per=99.87%, avg=53347.13, stdev=926.09, samples=156
   iops        : min=10379, max=14756, avg=13336.90, stdev=231.57, samples=156
  lat (msec)   : 2=1.09%, 4=10.99%, 10=11.48%, 20=0.61%, 100=70.52%
  lat (msec)   : 250=5.31%
  cpu          : usr=1.02%, sys=2.62%, ctx=41463, majf=0, minf=1067
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=99.9%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.1%
     issued rwts: total=267267,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=256

Run status group 0 (all jobs):
   READ: bw=52.2MiB/s (54.7MB/s), 52.2MiB/s-52.2MiB/s (54.7MB/s-54.7MB/s), io=1044MiB (1095MB), run=20013-20013msec
/mnt/netapp-nfs # 
```

## Azure Files Premium NFSv4.1

```bash
/mnt/nfs # fio --directory=perf-test --direct=1 --rw=randwrite --bs=4k --ioengine=libaio --iodepth=256 --runtime=20 --numjobs=4 --time_based --group_reporting --size=4m --name=iops-test-job --eta-newline=1
iops-test-job: (g=0): rw=randwrite, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=256
...
fio-3.27
Starting 4 processes
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
Jobs: 4 (f=4): [w(4)][20.0%][w=39.4MiB/s][w=10.1k IOPS][eta 00m:16s]
Jobs: 4 (f=4): [w(4)][25.0%][w=39.1MiB/s][w=10.0k IOPS][eta 00m:15s]
Jobs: 4 (f=4): [w(4)][30.0%][w=40.0MiB/s][w=10.2k IOPS][eta 00m:14s]
Jobs: 4 (f=4): [w(4)][38.1%][w=37.9MiB/s][w=9695 IOPS][eta 00m:13s] 
Jobs: 4 (f=4): [w(4)][45.0%][w=42.5MiB/s][w=10.9k IOPS][eta 00m:11s]
Jobs: 4 (f=4): [w(4)][55.0%][w=39.9MiB/s][w=10.2k IOPS][eta 00m:09s]
Jobs: 4 (f=4): [w(4)][60.0%][w=39.9MiB/s][w=10.2k IOPS][eta 00m:08s]
Jobs: 4 (f=4): [w(4)][70.0%][w=39.7MiB/s][w=10.2k IOPS][eta 00m:06s] 
Jobs: 4 (f=4): [w(4)][80.0%][w=41.4MiB/s][w=10.6k IOPS][eta 00m:04s] 
Jobs: 4 (f=4): [w(4)][90.0%][w=39.1MiB/s][w=10.0k IOPS][eta 00m:02s] 
Jobs: 4 (f=4): [w(4)][100.0%][w=39.1MiB/s][w=10.0k IOPS][eta 00m:00s]
Jobs: 4 (f=4): [w(4)][100.0%][w=39.0MiB/s][w=9990 IOPS][eta 00m:00s]
iops-test-job: (groupid=0, jobs=4): err= 0: pid=122: Thu Nov 25 09:28:33 2021
  write: IOPS=10.1k, BW=39.6MiB/s (41.6MB/s)(801MiB/20198msec); 0 zone resets
    slat (nsec): min=1800, max=97972k, avg=11899.38, stdev=567845.56
    clat (msec): min=2, max=1095, avg=100.87, stdev=52.50
     lat (msec): min=2, max=1095, avg=100.88, stdev=52.50
    clat percentiles (msec):
     |  1.00th=[   12],  5.00th=[   23], 10.00th=[   35], 20.00th=[   83],
     | 30.00th=[   87], 40.00th=[   95], 50.00th=[   99], 60.00th=[  100],
     | 70.00th=[  101], 80.00th=[  102], 90.00th=[  161], 95.00th=[  232],
     | 99.00th=[  296], 99.50th=[  300], 99.90th=[  300], 99.95th=[  300],
     | 99.99th=[  321]
   bw (  KiB/s): min=30576, max=50784, per=100.00%, avg=40782.20, stdev=1801.02, samples=160
   iops        : min= 7644, max=12696, avg=10195.40, stdev=450.23, samples=160
  lat (msec)   : 4=0.01%, 10=0.70%, 20=2.98%, 50=8.57%, 100=56.31%
  lat (msec)   : 250=28.39%, 500=3.04%, 750=0.01%, 1000=0.01%, 2000=0.01%
  cpu          : usr=1.09%, sys=2.29%, ctx=46249, majf=0, minf=47
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=99.9%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.1%
     issued rwts: total=0,204958,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=256

Run status group 0 (all jobs):
  WRITE: bw=39.6MiB/s (41.6MB/s), 39.6MiB/s-39.6MiB/s (41.6MB/s-41.6MB/s), io=801MiB (840MB), run=20198-20198msec
/mnt/nfs # 
```

```bash
/mnt/nfs # fio --directory=perf-test --direct=1 --rw=randread --bs=4k --ioengine=libaio --iodepth=256 --runtime=20 --numjobs=4 --time_based --group_reporting --size=4m --name=iops-test-job --eta-newline=1 --readonl
y
iops-test-job: (g=0): rw=randread, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=256
...
fio-3.27
Starting 4 processes
Jobs: 4 (f=4): [r(4)][19.0%][r=38.4MiB/s][r=9842 IOPS][eta 00m:17s]
Jobs: 4 (f=4): [r(4)][28.6%][r=39.4MiB/s][r=10.1k IOPS][eta 00m:15s] 
Jobs: 4 (f=4): [r(4)][33.3%][r=39.9MiB/s][r=10.2k IOPS][eta 00m:14s]
Jobs: 4 (f=4): [r(4)][40.0%][r=43.7MiB/s][r=11.2k IOPS][eta 00m:12s]
Jobs: 4 (f=4): [r(4)][50.0%][r=40.0MiB/s][r=10.2k IOPS][eta 00m:10s] 
Jobs: 4 (f=4): [r(4)][55.0%][r=36.1MiB/s][r=9230 IOPS][eta 00m:09s]
Jobs: 4 (f=4): [r(4)][60.0%][r=43.3MiB/s][r=11.1k IOPS][eta 00m:08s]
Jobs: 4 (f=4): [r(4)][65.0%][r=39.2MiB/s][r=10.0k IOPS][eta 00m:07s]
Jobs: 4 (f=4): [r(4)][75.0%][r=39.0MiB/s][r=9990 IOPS][eta 00m:05s]  
Jobs: 4 (f=4): [r(4)][80.0%][r=39.0MiB/s][r=9990 IOPS][eta 00m:04s]
Jobs: 4 (f=4): [r(4)][90.0%][r=39.4MiB/s][r=10.1k IOPS][eta 00m:02s] 
Jobs: 4 (f=4): [r(4)][95.0%][r=38.6MiB/s][r=9891 IOPS][eta 00m:01s]
Jobs: 4 (f=4): [r(4)][100.0%][r=39.0MiB/s][r=9980 IOPS][eta 00m:00s]  
iops-test-job: (groupid=0, jobs=4): err= 0: pid=130: Thu Nov 25 09:29:54 2021
  read: IOPS=10.2k, BW=39.8MiB/s (41.7MB/s)(804MiB/20213msec)
    slat (nsec): min=1500, max=98292k, avg=18769.60, stdev=1035846.72
    clat (msec): min=2, max=401, avg=100.46, stdev=60.72
     lat (msec): min=2, max=401, avg=100.48, stdev=60.72
    clat percentiles (msec):
     |  1.00th=[    5],  5.00th=[   12], 10.00th=[   19], 20.00th=[   80],
     | 30.00th=[   91], 40.00th=[   99], 50.00th=[  100], 60.00th=[  100],
     | 70.00th=[  101], 80.00th=[  101], 90.00th=[  188], 95.00th=[  247],
     | 99.00th=[  300], 99.50th=[  309], 99.90th=[  326], 99.95th=[  376],
     | 99.99th=[  384]
   bw (  KiB/s): min=26427, max=55228, per=100.00%, avg=40851.57, stdev=1965.45, samples=160
   iops        : min= 6606, max=13807, avg=10212.80, stdev=491.39, samples=160
  lat (msec)   : 4=0.84%, 10=3.45%, 20=6.45%, 50=4.08%, 100=58.40%
  lat (msec)   : 250=22.02%, 500=4.77%
  cpu          : usr=0.78%, sys=2.58%, ctx=53582, majf=0, minf=1073
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=99.9%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.1%
     issued rwts: total=205888,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=256

Run status group 0 (all jobs):
   READ: bw=39.8MiB/s (41.7MB/s), 39.8MiB/s-39.8MiB/s (41.7MB/s-41.7MB/s), io=804MiB (843MB), run=20213-20213msec
/mnt/nfs # 
```

## Azure Files Premium SMB

```bash
/mnt/smb # fio --directory=perf-test --direct=1 --rw=randwrite --bs=4k --ioengine=libaio --iodepth=256 --runtime=20 --numjobs=4 --time_based --group_reporting --size=4m --name=iops-test-job --eta-newline=1
iops-test-job: (g=0): rw=randwrite, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=256
...
fio-3.27
Starting 4 processes
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
Jobs: 4 (f=4): [w(4)][15.0%][w=9.95MiB/s][w=2547 IOPS][eta 00m:17s]
Jobs: 4 (f=4): [w(4)][25.0%][w=9605KiB/s][w=2401 IOPS][eta 00m:15s] 
Jobs: 4 (f=4): [w(4)][35.0%][w=8152KiB/s][w=2038 IOPS][eta 00m:13s] 
Jobs: 4 (f=4): [w(4)][40.0%][w=8655KiB/s][w=2163 IOPS][eta 00m:12s]
Jobs: 4 (f=4): [w(4)][45.0%][w=9200KiB/s][w=2300 IOPS][eta 00m:11s]
Jobs: 4 (f=4): [w(4)][50.0%][w=9154KiB/s][w=2288 IOPS][eta 00m:10s]
Jobs: 4 (f=4): [w(4)][60.0%][w=9668KiB/s][w=2417 IOPS][eta 00m:08s] 
Jobs: 4 (f=4): [w(4)][70.0%][w=9496KiB/s][w=2374 IOPS][eta 00m:06s] 
Jobs: 4 (f=4): [w(4)][75.0%][w=8839KiB/s][w=2209 IOPS][eta 00m:05s]
Jobs: 4 (f=4): [w(4)][80.0%][w=6925KiB/s][w=1731 IOPS][eta 00m:04s]
Jobs: 4 (f=4): [w(4)][85.0%][w=8511KiB/s][w=2127 IOPS][eta 00m:03s]
Jobs: 4 (f=4): [w(4)][95.0%][w=8016KiB/s][w=2004 IOPS][eta 00m:01s] 
Jobs: 4 (f=4): [w(4)][100.0%][w=8212KiB/s][w=2053 IOPS][eta 00m:00s]
iops-test-job: (groupid=0, jobs=4): err= 0: pid=140: Thu Nov 25 09:31:14 2021
  write: IOPS=2189, BW=8757KiB/s (8967kB/s)(171MiB/20010msec); 0 zone resets
    slat (usec): min=7, max=197976, avg=1769.29, stdev=12561.02
    clat (msec): min=4, max=1090, avg=460.97, stdev=196.99
     lat (msec): min=5, max=1090, avg=462.74, stdev=197.38
    clat percentiles (msec):
     |  1.00th=[   93],  5.00th=[  112], 10.00th=[  203], 20.00th=[  300],
     | 30.00th=[  309], 40.00th=[  401], 50.00th=[  489], 60.00th=[  502],
     | 70.00th=[  592], 80.00th=[  600], 90.00th=[  701], 95.00th=[  802],
     | 99.00th=[  902], 99.50th=[  902], 99.90th=[ 1003], 99.95th=[ 1003],
     | 99.99th=[ 1003]
   bw (  KiB/s): min= 2956, max=17915, per=98.79%, avg=8651.19, stdev=866.34, samples=155
   iops        : min=  739, max= 4478, avg=2162.62, stdev=216.58, samples=155
  lat (msec)   : 10=0.44%, 20=0.43%, 100=1.29%, 250=11.87%, 500=45.70%
  lat (msec)   : 750=31.59%, 1000=8.64%, 2000=0.03%
  cpu          : usr=0.19%, sys=3.24%, ctx=6462, majf=0, minf=46
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.3%, >=64=99.4%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.1%
     issued rwts: total=0,43807,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=256

Run status group 0 (all jobs):
  WRITE: bw=8757KiB/s (8967kB/s), 8757KiB/s-8757KiB/s (8967kB/s-8967kB/s), io=171MiB (179MB), run=20010-20010msec
/mnt/smb # 
```

```bash
/mnt/smb # fio --directory=perf-test --direct=1 --rw=randread --bs=4k --ioengine=libaio --iodepth=256 --runtime=20 --numjobs=4 --time_based --group_reporting --size=4m --name=iops-test-job --eta-newline=1 --readonl
y
iops-test-job: (g=0): rw=randread, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=256
...
fio-3.27
Starting 4 processes
Jobs: 4 (f=4): [r(4)][19.0%][r=16.1MiB/s][r=4129 IOPS][eta 00m:17s]
Jobs: 4 (f=4): [r(4)][28.6%][r=19.3MiB/s][r=4950 IOPS][eta 00m:15s] 
Jobs: 4 (f=4): [r(4)][33.3%][r=19.0MiB/s][r=4858 IOPS][eta 00m:14s]
Jobs: 4 (f=4): [r(4)][45.0%][r=18.5MiB/s][r=4736 IOPS][eta 00m:11s] 
Jobs: 4 (f=4): [r(4)][55.0%][r=19.1MiB/s][r=4889 IOPS][eta 00m:09s] 
Jobs: 4 (f=4): [r(4)][65.0%][r=17.5MiB/s][r=4468 IOPS][eta 00m:07s] 
Jobs: 4 (f=4): [r(4)][75.0%][r=15.3MiB/s][r=3913 IOPS][eta 00m:05s] 
Jobs: 4 (f=4): [r(4)][80.0%][r=16.4MiB/s][r=4197 IOPS][eta 00m:04s]
Jobs: 4 (f=4): [r(4)][85.0%][r=16.1MiB/s][r=4118 IOPS][eta 00m:03s]
Jobs: 4 (f=4): [r(4)][90.0%][r=17.2MiB/s][r=4407 IOPS][eta 00m:02s]
Jobs: 4 (f=4): [r(4)][95.0%][r=15.9MiB/s][r=4075 IOPS][eta 00m:01s]
Jobs: 4 (f=4): [r(4)][100.0%][r=17.0MiB/s][r=4349 IOPS][eta 00m:00s]
iops-test-job: (groupid=0, jobs=4): err= 0: pid=148: Thu Nov 25 09:31:59 2021
  read: IOPS=4319, BW=16.9MiB/s (17.7MB/s)(338MiB/20010msec)
    slat (usec): min=4, max=99758, avg=871.37, stdev=8746.00
    clat (msec): min=3, max=594, avg=235.24, stdev=105.42
     lat (msec): min=3, max=594, avg=236.11, stdev=105.58
    clat percentiles (msec):
     |  1.00th=[    7],  5.00th=[   96], 10.00th=[  101], 20.00th=[  107],
     | 30.00th=[  199], 40.00th=[  201], 50.00th=[  205], 60.00th=[  296],
     | 70.00th=[  300], 80.00th=[  300], 90.00th=[  397], 95.00th=[  401],
     | 99.00th=[  498], 99.50th=[  502], 99.90th=[  502], 99.95th=[  502],
     | 99.99th=[  502]
   bw (  KiB/s): min= 8916, max=30691, per=99.01%, avg=17105.85, stdev=1307.26, samples=156
   iops        : min= 2229, max= 7672, avg=4276.15, stdev=326.84, samples=156
  lat (msec)   : 4=0.01%, 10=1.91%, 20=1.46%, 100=6.66%, 250=45.20%
  lat (msec)   : 500=44.68%, 750=0.07%
  cpu          : usr=0.25%, sys=3.23%, ctx=16305, majf=0, minf=1066
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=99.7%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.1%
     issued rwts: total=86427,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=256

Run status group 0 (all jobs):
   READ: bw=16.9MiB/s (17.7MB/s), 16.9MiB/s-16.9MiB/s (17.7MB/s-17.7MB/s), io=338MiB (354MB), run=20010-20010msec
/mnt/smb # 
```

## Azure Disk - Ultra

Example test using `disk size (GiB): 250`, `Disk IOPS: 76800`, `Disk throughput (MB/s): 4000` and `CachingMode: None`.

> **Important**: Test have been executed using Virtual Machine SKU `Standard_D8ds_v4` which has `Max uncached disk throughput: 12800 IOPS, 192 MBps` and
`Max burst uncached disk throughput: IOPS/MBps: 16000 IOPS, 400 MBps`. It's limiting below performance numbers!

```bash
/mnt/ultradisk # fio --directory=perf-test --direct=1 --rw=randwrite --bs=4k --ioengine=libaio --iodepth=256 --runtime=20 --numjobs=4 --time_based --group_reporting --size=4m --name=iops-test-job --eta-newline=1
iops-test-job: (g=0): rw=randwrite, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=256
...
fio-3.27
Starting 4 processes
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
Jobs: 4 (f=4): [w(4)][19.0%][w=57.4MiB/s][w=14.7k IOPS][eta 00m:17s]
Jobs: 4 (f=4): [w(4)][23.8%][w=56.9MiB/s][w=14.6k IOPS][eta 00m:16s]
Jobs: 4 (f=4): [w(4)][35.0%][w=60.9MiB/s][w=15.6k IOPS][eta 00m:13s] 
Jobs: 4 (f=4): [w(4)][45.0%][w=60.9MiB/s][w=15.6k IOPS][eta 00m:11s] 
Jobs: 4 (f=4): [w(4)][50.0%][w=63.2MiB/s][w=16.2k IOPS][eta 00m:10s]
Jobs: 4 (f=4): [w(4)][55.0%][w=59.9MiB/s][w=15.3k IOPS][eta 00m:09s]
Jobs: 4 (f=4): [w(4)][65.0%][w=57.2MiB/s][w=14.6k IOPS][eta 00m:07s] 
Jobs: 4 (f=4): [w(4)][70.0%][w=58.4MiB/s][w=15.0k IOPS][eta 00m:06s]
Jobs: 4 (f=4): [w(4)][75.0%][w=62.4MiB/s][w=16.0k IOPS][eta 00m:05s]
Jobs: 4 (f=4): [w(4)][80.0%][w=59.0MiB/s][w=15.1k IOPS][eta 00m:04s]
Jobs: 4 (f=4): [w(4)][90.0%][w=60.0MiB/s][w=15.4k IOPS][eta 00m:02s] 
Jobs: 4 (f=4): [w(4)][100.0%][w=60.0MiB/s][w=15.3k IOPS][eta 00m:00s]
iops-test-job: (groupid=0, jobs=4): err= 0: pid=42: Fri Feb 18 10:45:51 2022
  write: IOPS=15.3k, BW=59.7MiB/s (62.6MB/s)(1199MiB/20085msec); 0 zone resets
    slat (nsec): min=1900, max=100178k, avg=67530.74, stdev=2337557.27
    clat (usec): min=272, max=297207, avg=66833.83, stdev=49235.22
     lat (usec): min=276, max=297219, avg=66902.18, stdev=49230.27
    clat percentiles (usec):
     |  1.00th=[  1598],  5.00th=[  2376], 10.00th=[  3195], 20.00th=[  5932],
     | 30.00th=[  9110], 40.00th=[ 85459], 50.00th=[ 93848], 60.00th=[ 96994],
     | 70.00th=[ 99091], 80.00th=[100140], 90.00th=[101188], 95.00th=[103285],
     | 99.00th=[198181], 99.50th=[198181], 99.90th=[200279], 99.95th=[200279],
     | 99.99th=[202376]
   bw (  KiB/s): min=39972, max=89136, per=100.00%, avg=61376.64, stdev=2583.28, samples=156
   iops        : min= 9992, max=22284, avg=15343.95, stdev=645.85, samples=156
  lat (usec)   : 500=0.07%, 750=0.12%, 1000=0.10%
  lat (msec)   : 2=2.72%, 4=10.83%, 10=18.12%, 20=4.30%, 50=0.04%
  lat (msec)   : 100=45.13%, 250=18.58%, 500=0.01%
  cpu          : usr=0.86%, sys=2.58%, ctx=93773, majf=0, minf=53
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=99.9%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.1%
     issued rwts: total=0,306913,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=256

Run status group 0 (all jobs):
  WRITE: bw=59.7MiB/s (62.6MB/s), 59.7MiB/s-59.7MiB/s (62.6MB/s-62.6MB/s), io=1199MiB (1257MB), run=20085-20085msec

Disk stats (read/write):
  sdc: ios=0/297129, merge=0/6854, ticks=0/2434030, in_queue=1842628, util=28.22%
```

```bash
/mnt/ultradisk # fio --directory=perf-test --direct=1 --rw=randread --bs=4k --ioengine=libaio --iodepth=256 --runtime=20 --numjobs=4 --time_based --group_reporting --size=4m --name=iops-test-job --eta-newline=1 --readonly
iops-test-job: (g=0): rw=randread, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=256
...
fio-3.27
Starting 4 processes
Jobs: 4 (f=4): [r(4)][14.3%][r=67.2MiB/s][r=17.2k IOPS][eta 00m:18s]
Jobs: 4 (f=4): [r(4)][23.8%][r=66.0MiB/s][r=16.9k IOPS][eta 00m:16s] 
Jobs: 4 (f=4): [r(4)][33.3%][r=67.7MiB/s][r=17.3k IOPS][eta 00m:14s] 
Jobs: 4 (f=4): [r(4)][42.9%][r=66.6MiB/s][r=17.0k IOPS][eta 00m:12s] 
Jobs: 4 (f=4): [r(4)][47.6%][r=61.0MiB/s][r=15.6k IOPS][eta 00m:11s]
Jobs: 4 (f=4): [r(4)][57.1%][r=67.1MiB/s][r=17.2k IOPS][eta 00m:09s] 
Jobs: 4 (f=4): [r(4)][65.0%][r=68.6MiB/s][r=17.6k IOPS][eta 00m:07s]
Jobs: 4 (f=4): [r(4)][75.0%][r=68.8MiB/s][r=17.6k IOPS][eta 00m:05s] 
Jobs: 4 (f=4): [r(4)][85.0%][r=68.8MiB/s][r=17.6k IOPS][eta 00m:03s] 
Jobs: 4 (f=4): [r(4)][95.0%][r=63.1MiB/s][r=16.2k IOPS][eta 00m:01s] 
Jobs: 4 (f=3): [r(1),f(1),r(2)][100.0%][r=64.5MiB/s][r=16.5k IOPS][eta 00m:00s]
iops-test-job: (groupid=0, jobs=4): err= 0: pid=51: Fri Feb 18 10:46:21 2022
  read: IOPS=17.0k, BW=66.5MiB/s (69.7MB/s)(1335MiB/20092msec)
    slat (nsec): min=1500, max=100131k, avg=39572.09, stdev=1477577.19
    clat (usec): min=269, max=265185, avg=60048.59, stdev=37757.82
     lat (usec): min=331, max=265188, avg=60088.76, stdev=37747.49
    clat percentiles (usec):
     |  1.00th=[  1385],  5.00th=[  2540], 10.00th=[  4490], 20.00th=[ 19268],
     | 30.00th=[ 38011], 40.00th=[ 47973], 50.00th=[ 59507], 60.00th=[ 68682],
     | 70.00th=[ 93848], 80.00th=[ 98042], 90.00th=[100140], 95.00th=[101188],
     | 99.00th=[154141], 99.50th=[187696], 99.90th=[200279], 99.95th=[208667],
     | 99.99th=[261096]
   bw (  KiB/s): min=50118, max=98888, per=100.00%, avg=68333.26, stdev=2486.72, samples=156
   iops        : min=12529, max=24722, avg=17083.18, stdev=621.73, samples=156
  lat (usec)   : 500=0.03%, 750=0.13%, 1000=0.15%
  lat (msec)   : 2=2.76%, 4=6.01%, 10=9.01%, 20=1.99%, 50=21.29%
  lat (msec)   : 100=48.41%, 250=10.20%, 500=0.03%
  cpu          : usr=0.82%, sys=2.73%, ctx=144685, majf=0, minf=1074
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=99.9%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.1%
     issued rwts: total=341868,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=256

Run status group 0 (all jobs):
   READ: bw=66.5MiB/s (69.7MB/s), 66.5MiB/s-66.5MiB/s (69.7MB/s-69.7MB/s), io=1335MiB (1400MB), run=20092-20092msec

Disk stats (read/write):
  sdc: ios=332134/2, merge=9569/27, ticks=13087353/2, in_queue=12425804, util=85.68%
```

## Azure Disk - Premium P4

Example test using `P4 - 120 IOPS, 25 MBps`. Note: In below test you can see that you're
able to reach to `Max burst IOPS` of the `P4`.

See [Premium storage disk sizes](https://docs.microsoft.com/en-us/azure/virtual-machines/premium-storage-performance#premium-storage-disk-sizes)
for information about disk performance and pricing.

```bash
/mnt/premiumdisk # fio --directory=perf-test --direct=1 --rw=randwrite --bs=4k --ioengine=libaio --iodepth=256 --runtime=20 --numjobs=4 --time_based --group_reporting --size=4m --name=iops-test-job --eta-newline=1
iops-test-job: (g=0): rw=randwrite, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=256
...
fio-3.27
Starting 4 processes
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
Jobs: 4 (f=4): [w(4)][15.0%][w=11.3MiB/s][w=2881 IOPS][eta 00m:17s]
Jobs: 4 (f=4): [w(4)][25.0%][w=14.1MiB/s][w=3618 IOPS][eta 00m:15s] 
Jobs: 4 (f=4): [w(4)][35.0%][w=14.1MiB/s][w=3609 IOPS][eta 00m:13s] 
Jobs: 4 (f=4): [w(4)][45.0%][w=14.2MiB/s][w=3623 IOPS][eta 00m:11s] 
Jobs: 4 (f=4): [w(4)][55.0%][w=14.1MiB/s][w=3603 IOPS][eta 00m:09s] 
Jobs: 4 (f=4): [w(4)][65.0%][w=14.1MiB/s][w=3599 IOPS][eta 00m:07s] 
Jobs: 4 (f=4): [w(4)][75.0%][w=14.2MiB/s][w=3639 IOPS][eta 00m:05s] 
Jobs: 4 (f=4): [w(4)][85.0%][w=14.0MiB/s][w=3589 IOPS][eta 00m:03s] 
Jobs: 4 (f=4): [w(4)][95.0%][w=14.0MiB/s][w=3588 IOPS][eta 00m:01s] 
Jobs: 4 (f=4): [w(4)][100.0%][w=14.1MiB/s][w=3618 IOPS][eta 00m:00s]
iops-test-job: (groupid=0, jobs=4): err= 0: pid=64: Wed Feb 16 12:45:48 2022
  write: IOPS=3254, BW=12.7MiB/s (13.3MB/s)(257MiB/20253msec); 0 zone resets
    slat (usec): min=2, max=82067, avg=11.80, stdev=319.74
    clat (msec): min=2, max=2711, avg=314.58, stdev=263.08
     lat (msec): min=2, max=2711, avg=314.59, stdev=263.09
    clat percentiles (msec):
     |  1.00th=[  100],  5.00th=[  106], 10.00th=[  146], 20.00th=[  201],
     | 30.00th=[  205], 40.00th=[  241], 50.00th=[  251], 60.00th=[  284],
     | 70.00th=[  309], 80.00th=[  397], 90.00th=[  506], 95.00th=[  600],
     | 99.00th=[ 2106], 99.50th=[ 2198], 99.90th=[ 2467], 99.95th=[ 2668],
     | 99.99th=[ 2702]
   bw (  KiB/s): min=  544, max=17840, per=100.00%, avg=13504.84, stdev=903.18, samples=154
   iops        : min=  136, max= 4460, avg=3376.26, stdev=225.79, samples=154
  lat (msec)   : 4=0.01%, 10=0.01%, 50=0.08%, 100=1.15%, 250=48.40%
  lat (msec)   : 500=39.43%, 750=8.93%, 1000=0.40%, 2000=0.38%, >=2000=1.23%
  cpu          : usr=0.38%, sys=1.22%, ctx=76728, majf=0, minf=53
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.2%, >=64=99.6%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.1%
     issued rwts: total=0,65907,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=256

Run status group 0 (all jobs):
  WRITE: bw=12.7MiB/s (13.3MB/s), 12.7MiB/s-12.7MiB/s (13.3MB/s-13.3MB/s), io=257MiB (270MB), run=20253-20253msec

Disk stats (read/write):
  sdc: ios=0/63438, merge=0/2023, ticks=0/19790632, in_queue=19663492, util=99.36%
```

```bash
/mnt/premiumdisk # fio --directory=perf-test --direct=1 --rw=randread --bs=4k --ioengine=libaio --iodepth=256 --runtime=20 --numjobs=4 --time_based --group_reporting --size=4m --name=iops-test-job --eta-newline=1 --readon
ly
iops-test-job: (g=0): rw=randread, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=256
...
fio-3.27
Starting 4 processes
Jobs: 4 (f=4): [r(4)][14.3%][r=93.1MiB/s][r=23.8k IOPS][eta 00m:18s]
Jobs: 4 (f=4): [r(4)][23.8%][r=98.5MiB/s][r=25.2k IOPS][eta 00m:16s] 
Jobs: 4 (f=4): [r(4)][33.3%][r=92.2MiB/s][r=23.6k IOPS][eta 00m:14s] 
Jobs: 4 (f=4): [r(4)][45.0%][r=97.1MiB/s][r=24.9k IOPS][eta 00m:11s] 
Jobs: 4 (f=4): [r(4)][55.0%][r=89.4MiB/s][r=22.9k IOPS][eta 00m:09s] 
Jobs: 4 (f=4): [r(4)][60.0%][r=82.0MiB/s][r=21.0k IOPS][eta 00m:08s]
Jobs: 4 (f=4): [r(4)][65.0%][r=90.4MiB/s][r=23.1k IOPS][eta 00m:07s]
Jobs: 4 (f=4): [r(4)][70.0%][r=83.7MiB/s][r=21.4k IOPS][eta 00m:06s]
Jobs: 4 (f=4): [r(4)][75.0%][r=97.1MiB/s][r=24.9k IOPS][eta 00m:05s]
Jobs: 4 (f=4): [r(4)][85.0%][r=82.7MiB/s][r=21.2k IOPS][eta 00m:03s] 
Jobs: 4 (f=4): [r(4)][90.0%][r=91.4MiB/s][r=23.4k IOPS][eta 00m:02s]
Jobs: 4 (f=4): [r(4)][100.0%][r=93.5MiB/s][r=23.9k IOPS][eta 00m:00s]
iops-test-job: (groupid=0, jobs=4): err= 0: pid=72: Wed Feb 16 12:46:45 2022
  read: IOPS=23.1k, BW=90.3MiB/s (94.7MB/s)(1824MiB/20192msec)
    slat (nsec): min=1600, max=199049k, avg=118672.70, stdev=3340826.41
    clat (usec): min=102, max=400026, avg=44025.81, stdev=68387.88
     lat (usec): min=204, max=400033, avg=44146.89, stdev=68519.06
    clat percentiles (usec):
     |  1.00th=[   988],  5.00th=[  1012], 10.00th=[  1057], 20.00th=[  1270],
     | 30.00th=[  1369], 40.00th=[  1516], 50.00th=[  1713], 60.00th=[  2114],
     | 70.00th=[ 92799], 80.00th=[ 96994], 90.00th=[101188], 95.00th=[200279],
     | 99.00th=[295699], 99.50th=[299893], 99.90th=[392168], 99.95th=[396362],
     | 99.99th=[400557]
   bw (  KiB/s): min=17672, max=239048, per=100.00%, avg=93191.79, stdev=13442.20, samples=156
   iops        : min= 4418, max=59760, avg=23297.62, stdev=3360.54, samples=156
  lat (usec)   : 250=0.01%, 500=0.08%, 750=0.17%, 1000=2.15%
  lat (msec)   : 2=55.79%, 4=8.48%, 10=0.14%, 100=17.47%, 250=14.48%
  lat (msec)   : 500=1.25%
  cpu          : usr=0.95%, sys=2.69%, ctx=5225, majf=0, minf=1081
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=99.9%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.1%
     issued rwts: total=466977,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=256

Run status group 0 (all jobs):
   READ: bw=90.3MiB/s (94.7MB/s), 90.3MiB/s-90.3MiB/s (94.7MB/s-94.7MB/s), io=1824MiB (1913MB), run=20192-20192msec

Disk stats (read/write):
  sdc: ios=466755/0, merge=221/0, ticks=307498/0, in_queue=20, util=14.50%
```

### Example disk perf analysis

Here is example disk performance analysis using `fio` tool.

These are the commands used to run the tests:

```bash
# Write test
fio --directory=perf-test --direct=1 --rw=randwrite --bs=4k --ioengine=libaio --iodepth=256 --runtime=200 --numjobs=8 --time_based --group_reporting --size=4m --name=iops-test-job --eta-newline=1

# Read test
fio --directory=perf-test --direct=1 --rw=randread --bs=4k --ioengine=libaio --iodepth=256 --runtime=20000 --numjobs=8 --time_based --group_reporting --size=4m --name=iops-test-job --eta-newline=1 --readonly
```

Disk is deployed using following storage class:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: perf-test-sc
provisioner: disk.csi.azure.com
parameters:
  enableBursting: "true" # <- Enable on-demand bursting
  skuName: Premium_LRS
  cachingmode: None      # <- Disable caching to see the raw disk performance
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

And with the following PVC:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: perf-test-pvc
  namespace: demos
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: perf-test-sc
  resources:
    requests:
      storage: 8192Gi # <- Disk size: 1024Gi or 8192Gi
```

_Test 1:_

- VM: [Standard_D8ds_v4](https://learn.microsoft.com/en-us/azure/virtual-machines/ddv4-ddsv4-series)
  - Max uncached disk throughput: **12'800 IOPS, 192 MBps**
  - Max burst uncached disk throughput: **16'000 IOPS, 400 MBps**
- Disk: [P30 - 1024Gi](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-scalability-targets#premium-ssd-managed-disks-per-disk-limits)
  - Base provisioned IOPS per disk: **5000 IOPS**
  - Base provisioned Throughput per disk: **200 MB/s**
  - Max burst IOPS per disk: **30,000 IOPS**
  - Max burst throughput per disk: **1,000 MB/s**

Write & Read test results (`cachingmode: None` removes caching impact):

```bash
Jobs: 4 (f=4): [w(4)][15.0%][w=66.2MiB/s][w=16.9k IOPS][eta 00m:17s]
Jobs: 4 (f=4): [w(4)][25.0%][w=64.4MiB/s][w=16.5k IOPS][eta 00m:15s] 
Jobs: 4 (f=4): [w(4)][35.0%][w=65.8MiB/s][w=16.8k IOPS][eta 00m:13s] 
Jobs: 4 (f=4): [w(4)][45.0%][w=65.0MiB/s][w=16.7k IOPS][eta 00m:11s] 
Jobs: 4 (f=4): [w(4)][55.0%][w=65.9MiB/s][w=16.9k IOPS][eta 00m:09s]
```

| Test IOPS  | Test throughput | Analysis                                            |
| ---------- | --------------- | --------------------------------------------------- |
| 16'000     | 71 MBps         | **Limiting factor is VM with IOPS limit of 16'000** |

_Test 2:_

- VM: [Standard_E48ds_v5](https://learn.microsoft.com/en-us/azure/virtual-machines/edv5-edsv5-series)
  - Max uncached disk throughput: **76'800 IOPS, 1315 MBps**
  - Max burst uncached disk throughput: **80'000 IOPS, 3'000 MBps**
- Disk: [P60 - 8192Gi](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-scalability-targets#premium-ssd-managed-disks-per-disk-limits)
  - Base provisioned IOPS per disk: **16'000 IOPS**
  - Base provisioned Throughput per disk: **500 MB/s**
  - Max burst IOPS per disk: **30,000 IOPS**
  - Max burst throughput per disk: **1,000 MB/s**

Write & Read test results (`cachingmode: None` removes caching impact):

```bash
Jobs: 8 (f=8): [r(8)][0.2%][r=123MiB/s][r=31.5k IOPS][eta 05h:32m:45s] 
Jobs: 8 (f=8): [r(8)][0.2%][r=122MiB/s][r=31.2k IOPS][eta 05h:32m:43s] 
Jobs: 8 (f=8): [r(8)][0.2%][r=124MiB/s][r=31.6k IOPS][eta 05h:32m:41s]  
Jobs: 8 (f=8): [r(8)][0.2%][r=123MiB/s][r=31.4k IOPS][eta 05h:32m:39s] 
Jobs: 8 (f=8): [r(8)][0.2%][r=122MiB/s][r=31.3k IOPS][eta 05h:32m:37s] 
```

| Test IOPS  | Test throughput | Analysis                                                                |
| ---------- | --------------- | ----------------------------------------------------------------------- |
| 31'000     | 128 MBps        | **Limiting factor is disk _even_ with burst with IOPS limit of 30'000** |

Note: This test was done with P60 but there is no difference in burst IOPS between
[P30 and P60](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-scalability-targets#premium-ssd-managed-disks-per-disk-limits)
.

## emptyDir

[emptyDir](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir)

```bash
/mnt/empty # fio --directory=perf-test --direct=1 --rw=randwrite --bs=4k --ioengine=libaio --iodepth=256 --runtime=20 --numjobs=4 --time_based --group_reporting --size=4m --name=iops-test-job --eta-newline=1
iops-test-job: (g=0): rw=randwrite, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=256
...
fio-3.27
Starting 4 processes
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
Jobs: 4 (f=4): [w(4)][19.0%][w=70.0MiB/s][w=17.9k IOPS][eta 00m:17s]
Jobs: 4 (f=4): [w(4)][23.8%][w=63.0MiB/s][w=16.1k IOPS][eta 00m:16s]
Jobs: 4 (f=4): [w(4)][33.3%][w=69.7MiB/s][w=17.8k IOPS][eta 00m:14s] 
Jobs: 4 (f=4): [w(4)][38.1%][w=69.8MiB/s][w=17.9k IOPS][eta 00m:13s]
Jobs: 4 (f=4): [w(4)][45.0%][w=68.0MiB/s][w=17.4k IOPS][eta 00m:11s]
Jobs: 4 (f=4): [w(4)][50.0%][w=73.6MiB/s][w=18.9k IOPS][eta 00m:10s]
Jobs: 4 (f=4): [w(4)][55.0%][w=73.3MiB/s][w=18.8k IOPS][eta 00m:09s]
Jobs: 4 (f=4): [w(4)][60.0%][w=76.5MiB/s][w=19.6k IOPS][eta 00m:08s]
Jobs: 4 (f=4): [w(4)][70.0%][w=70.3MiB/s][w=18.0k IOPS][eta 00m:06s] 
Jobs: 4 (f=4): [w(4)][80.0%][w=76.0MiB/s][w=19.5k IOPS][eta 00m:04s] 
Jobs: 4 (f=4): [w(4)][90.0%][w=73.0MiB/s][w=18.7k IOPS][eta 00m:02s] 
Jobs: 4 (f=4): [w(4)][95.0%][w=66.3MiB/s][w=17.0k IOPS][eta 00m:01s]
Jobs: 4 (f=4): [w(4)][100.0%][w=69.7MiB/s][w=17.8k IOPS][eta 00m:00s]
iops-test-job: (groupid=0, jobs=4): err= 0: pid=37: Wed Dec 15 12:45:20 2021
  write: IOPS=17.7k, BW=69.1MiB/s (72.5MB/s)(1384MiB/20010msec); 0 zone resets
    slat (nsec): min=2000, max=104470k, avg=70961.26, stdev=2445347.87
    clat (usec): min=133, max=289622, avg=57756.08, stdev=50613.94
     lat (usec): min=153, max=289626, avg=57827.42, stdev=50628.43
    clat percentiles (usec):
     |  1.00th=[  1631],  5.00th=[  2245], 10.00th=[  3032], 20.00th=[  5276],
     | 30.00th=[  7701], 40.00th=[ 10028], 50.00th=[ 85459], 60.00th=[ 91751],
     | 70.00th=[ 96994], 80.00th=[ 99091], 90.00th=[100140], 95.00th=[102237],
     | 99.00th=[198181], 99.50th=[198181], 99.90th=[200279], 99.95th=[200279],
     | 99.99th=[200279]
   bw (  KiB/s): min=44845, max=107710, per=100.00%, avg=70856.95, stdev=3676.59, samples=156
   iops        : min=11211, max=26927, avg=17713.95, stdev=919.17, samples=156
  lat (usec)   : 250=0.01%, 500=0.01%, 750=0.02%, 1000=0.01%
  lat (msec)   : 2=3.77%, 4=11.09%, 10=24.96%, 20=5.76%, 50=0.01%
  lat (msec)   : 100=41.00%, 250=13.39%, 500=0.01%
  cpu          : usr=0.88%, sys=2.78%, ctx=96511, majf=0, minf=48
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=99.9%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.1%
     issued rwts: total=0,354225,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=256

Run status group 0 (all jobs):
  WRITE: bw=69.1MiB/s (72.5MB/s), 69.1MiB/s-69.1MiB/s (72.5MB/s-72.5MB/s), io=1384MiB (1451MB), run=20010-20010msec

Disk stats (read/write):
  sda: ios=1/343750, merge=0/8621, ticks=21/2471511, in_queue=1783932, util=24.95%
```

```bash
/mnt/empty # fio --directory=perf-test --direct=1 --rw=randread --bs=4k --ioengine=libaio --iodepth=256 --runtime=20 --numjobs=4 --time_based --group_reporting --size=4m --name=iops-test-job --eta-newline=1 --readonly
iops-test-job: (g=0): rw=randread, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=256
...
fio-3.27
Starting 4 processes
Jobs: 4 (f=4): [r(4)][19.0%][r=71.5MiB/s][r=18.3k IOPS][eta 00m:17s]
Jobs: 4 (f=4): [r(4)][28.6%][r=71.8MiB/s][r=18.4k IOPS][eta 00m:15s] 
Jobs: 4 (f=4): [r(4)][38.1%][r=78.4MiB/s][r=20.1k IOPS][eta 00m:13s] 
Jobs: 4 (f=4): [r(4)][45.0%][r=75.9MiB/s][r=19.4k IOPS][eta 00m:11s]
Jobs: 4 (f=4): [r(4)][50.0%][r=76.1MiB/s][r=19.5k IOPS][eta 00m:10s]
Jobs: 4 (f=4): [r(4)][55.0%][r=80.2MiB/s][r=20.5k IOPS][eta 00m:09s]
Jobs: 4 (f=4): [r(4)][65.0%][r=77.3MiB/s][r=19.8k IOPS][eta 00m:07s] 
Jobs: 4 (f=4): [r(4)][70.0%][r=83.8MiB/s][r=21.5k IOPS][eta 00m:06s]
Jobs: 4 (f=4): [r(4)][80.0%][r=74.9MiB/s][r=19.2k IOPS][eta 00m:04s] 
Jobs: 4 (f=4): [r(4)][90.0%][r=76.5MiB/s][r=19.6k IOPS][eta 00m:02s] 
Jobs: 4 (f=4): [r(4)][95.0%][r=71.9MiB/s][r=18.4k IOPS][eta 00m:01s]
Jobs: 4 (f=4): [r(4)][100.0%][r=83.8MiB/s][r=21.4k IOPS][eta 00m:00s]
iops-test-job: (groupid=0, jobs=4): err= 0: pid=51: Wed Dec 15 12:46:54 2021
  read: IOPS=19.5k, BW=76.1MiB/s (79.8MB/s)(1530MiB/20088msec)
    slat (nsec): min=1600, max=197911k, avg=58061.61, stdev=2191659.03
    clat (usec): min=223, max=297988, avg=52408.92, stdev=47571.54
     lat (usec): min=235, max=297994, avg=52467.13, stdev=47582.11
    clat percentiles (usec):
     |  1.00th=[  1418],  5.00th=[  2212], 10.00th=[  3032], 20.00th=[  5473],
     | 30.00th=[  7701], 40.00th=[  9503], 50.00th=[ 77071], 60.00th=[ 88605],
     | 70.00th=[ 92799], 80.00th=[ 98042], 90.00th=[100140], 95.00th=[100140],
     | 99.00th=[191890], 99.50th=[198181], 99.90th=[200279], 99.95th=[202376],
     | 99.99th=[295699]
   bw (  KiB/s): min=43686, max=119056, per=100.00%, avg=78244.03, stdev=4185.49, samples=156
   iops        : min=10921, max=29764, avg=19560.69, stdev=1046.38, samples=156
  lat (usec)   : 250=0.01%, 500=0.01%, 750=0.01%, 1000=0.03%
  lat (msec)   : 2=3.87%, 4=10.53%, 10=27.36%, 20=7.60%, 50=0.04%
  lat (msec)   : 100=41.88%, 250=8.65%, 500=0.03%
  cpu          : usr=0.93%, sys=2.69%, ctx=117738, majf=0, minf=1083
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=99.9%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.1%
     issued rwts: total=391577,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=256

Run status group 0 (all jobs):
   READ: bw=76.1MiB/s (79.8MB/s), 76.1MiB/s-76.1MiB/s (79.8MB/s-79.8MB/s), io=1530MiB (1604MB), run=20088-20088msec

Disk stats (read/write):
  sda: ios=378035/211, merge=10834/4, ticks=2885813/54, in_queue=2128728, util=26.73%
```

## hostPath

[hostPath](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath)

`/dev/sda1` is OS disk and `/dev/sdb1` is temp disk mounted at `/mnt` at host:

```bash
/mnt/hostpath $ df -h
Filesystem                Size      Used Available Use% Mounted on
overlay                 123.9G     18.7G    105.1G  15% /
tmpfs                    64.0M         0     64.0M   0% /dev
tmpfs                    15.7G         0     15.7G   0% /sys/fs/cgroup
/dev/sda1               123.9G     18.7G    105.1G  15% /mnt/empty
/dev/sdb1               294.3G     80.1M    279.2G   0% /mnt/hostpath
```

Using [Standard_D8ds_v4](https://docs.microsoft.com/en-us/azure/virtual-machines/ddv4-ddsv4-series#ddsv4-series) as VM size and it has `300 GB` temp storage.

Below are numbers for above "temp disk":

```yaml
volumes:
- name: hostpath
  hostPath:
    path: /mnt
```

```bash
/mnt/hostpath # fio --directory=perf-test --direct=1 --rw=randwrite --bs=4k --ioengine=libaio --iodepth=256 --runtime=20 --numjobs=4 --time_based --group_reporting --size=4m --name=iops-test-job --eta-newline=1
iops-test-job: (g=0): rw=randwrite, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=256
...
fio-3.27
Starting 4 processes
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
Jobs: 4 (f=4): [w(4)][20.0%][w=63.3MiB/s][w=16.2k IOPS][eta 00m:16s]
Jobs: 4 (f=4): [w(4)][30.0%][w=86.7MiB/s][w=22.2k IOPS][eta 00m:14s] 
Jobs: 4 (f=4): [w(4)][35.0%][w=78.8MiB/s][w=20.2k IOPS][eta 00m:13s]
Jobs: 4 (f=4): [w(4)][40.0%][w=70.9MiB/s][w=18.2k IOPS][eta 00m:12s]
Jobs: 4 (f=4): [w(4)][45.0%][w=65.7MiB/s][w=16.8k IOPS][eta 00m:11s]
Jobs: 4 (f=4): [w(4)][55.0%][w=58.3MiB/s][w=14.9k IOPS][eta 00m:09s] 
Jobs: 4 (f=4): [w(4)][60.0%][w=58.9MiB/s][w=15.1k IOPS][eta 00m:08s]
Jobs: 4 (f=4): [w(4)][65.0%][w=55.7MiB/s][w=14.3k IOPS][eta 00m:07s]
Jobs: 4 (f=4): [w(4)][70.0%][w=58.4MiB/s][w=14.9k IOPS][eta 00m:06s]
Jobs: 4 (f=4): [w(4)][75.0%][w=67.4MiB/s][w=17.3k IOPS][eta 00m:05s]
Jobs: 4 (f=4): [w(4)][80.0%][w=79.1MiB/s][w=20.2k IOPS][eta 00m:04s]
Jobs: 4 (f=4): [w(4)][85.0%][w=90.1MiB/s][w=23.1k IOPS][eta 00m:03s]
Jobs: 4 (f=4): [w(4)][90.0%][w=61.0MiB/s][w=15.6k IOPS][eta 00m:02s]
Jobs: 4 (f=4): [w(4)][95.0%][w=64.7MiB/s][w=16.6k IOPS][eta 00m:01s]
Jobs: 4 (f=4): [w(4)][100.0%][w=71.9MiB/s][w=18.4k IOPS][eta 00m:00s]
iops-test-job: (groupid=0, jobs=4): err= 0: pid=33: Wed Dec 15 13:03:55 2021
  write: IOPS=17.6k, BW=68.9MiB/s (72.3MB/s)(1385MiB/20093msec); 0 zone resets
    slat (usec): min=2, max=100770, avg=157.77, stdev=3822.95
    clat (usec): min=24, max=202535, avg=57822.92, stdev=53725.54
     lat (usec): min=321, max=202543, avg=57982.20, stdev=53780.45
    clat percentiles (usec):
     |  1.00th=[  1090],  5.00th=[  1123], 10.00th=[  1385], 20.00th=[  1713],
     | 30.00th=[  2147], 40.00th=[  2638], 50.00th=[ 94897], 60.00th=[ 99091],
     | 70.00th=[ 99091], 80.00th=[100140], 90.00th=[100140], 95.00th=[101188],
     | 99.00th=[198181], 99.50th=[198181], 99.90th=[200279], 99.95th=[200279],
     | 99.99th=[202376]
   bw (  KiB/s): min=33210, max=159472, per=100.00%, avg=70774.44, stdev=6745.00, samples=156
   iops        : min= 8302, max=39868, avg=17693.49, stdev=1686.26, samples=156
  lat (usec)   : 50=0.01%, 250=0.01%, 500=0.01%, 750=0.03%, 1000=0.26%
  lat (msec)   : 2=26.33%, 4=18.17%, 10=0.43%, 20=0.07%, 50=0.07%
  lat (msec)   : 100=40.53%, 250=14.12%
  cpu          : usr=0.95%, sys=2.65%, ctx=7584, majf=0, minf=62
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=99.9%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.1%
     issued rwts: total=0,354483,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=256

Run status group 0 (all jobs):
  WRITE: bw=68.9MiB/s (72.3MB/s), 68.9MiB/s-68.9MiB/s (72.3MB/s-72.3MB/s), io=1385MiB (1452MB), run=20093-20093msec

Disk stats (read/write):
  sdb: ios=0/351581, merge=0/987, ticks=0/503347, in_queue=23236, util=10.72%
/mnt/hostpath # 
```

```bash
/mnt/hostpath # fio --directory=perf-test --direct=1 --rw=randread --bs=4k --ioengine=libaio --iodepth=256 --runtime=20 --numjobs=4 --time_based --group_reporting --size=4m --name=iops-test-job --eta-newline=1 --readonly
iops-test-job: (g=0): rw=randread, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=256
...
fio-3.27
Starting 4 processes
Jobs: 4 (f=4): [r(4)][14.3%][r=79.1MiB/s][r=20.2k IOPS][eta 00m:18s]
Jobs: 4 (f=4): [r(4)][23.8%][r=77.4MiB/s][r=19.8k IOPS][eta 00m:16s] 
Jobs: 4 (f=4): [r(4)][30.0%][r=70.0MiB/s][r=17.9k IOPS][eta 00m:14s]
Jobs: 4 (f=4): [r(4)][40.0%][r=79.6MiB/s][r=20.4k IOPS][eta 00m:12s] 
Jobs: 4 (f=4): [r(4)][45.0%][r=82.6MiB/s][r=21.1k IOPS][eta 00m:11s]
Jobs: 4 (f=4): [r(4)][50.0%][r=77.6MiB/s][r=19.9k IOPS][eta 00m:10s]
Jobs: 4 (f=4): [r(4)][55.0%][r=61.3MiB/s][r=15.7k IOPS][eta 00m:09s]
Jobs: 4 (f=4): [r(4)][60.0%][r=85.1MiB/s][r=21.8k IOPS][eta 00m:08s]
Jobs: 4 (f=4): [r(4)][65.0%][r=80.7MiB/s][r=20.7k IOPS][eta 00m:07s]
Jobs: 4 (f=4): [r(4)][70.0%][r=70.9MiB/s][r=18.2k IOPS][eta 00m:06s]
Jobs: 4 (f=4): [r(4)][75.0%][r=92.4MiB/s][r=23.7k IOPS][eta 00m:05s]
Jobs: 4 (f=4): [r(4)][80.0%][r=85.2MiB/s][r=21.8k IOPS][eta 00m:04s]
Jobs: 4 (f=4): [r(4)][85.0%][r=78.0MiB/s][r=20.0k IOPS][eta 00m:03s]
Jobs: 4 (f=4): [r(4)][90.0%][r=77.8MiB/s][r=19.9k IOPS][eta 00m:02s]
Jobs: 4 (f=4): [r(4)][95.0%][r=62.7MiB/s][r=16.1k IOPS][eta 00m:01s]
Jobs: 4 (f=4): [r(4)][100.0%][r=70.4MiB/s][r=18.0k IOPS][eta 00m:00s]
iops-test-job: (groupid=0, jobs=4): err= 0: pid=46: Wed Dec 15 13:05:29 2021
  read: IOPS=20.1k, BW=78.4MiB/s (82.2MB/s)(1575MiB/20093msec)
    slat (nsec): min=1500, max=197769k, avg=110994.59, stdev=3209112.44
    clat (usec): min=37, max=299561, avg=50851.64, stdev=54610.29
     lat (usec): min=218, max=299565, avg=50964.47, stdev=54664.28
    clat percentiles (usec):
     |  1.00th=[   971],  5.00th=[  1090], 10.00th=[  1336], 20.00th=[  1647],
     | 30.00th=[  1991], 40.00th=[  2343], 50.00th=[  3785], 60.00th=[ 94897],
     | 70.00th=[ 98042], 80.00th=[ 99091], 90.00th=[100140], 95.00th=[101188],
     | 99.00th=[198181], 99.50th=[200279], 99.90th=[200279], 99.95th=[295699],
     | 99.99th=[299893]
   bw (  KiB/s): min=34556, max=163576, per=100.00%, avg=80598.05, stdev=7913.29, samples=156
   iops        : min= 8638, max=40894, avg=20149.36, stdev=1978.36, samples=156
  lat (usec)   : 50=0.01%, 250=0.01%, 500=0.01%, 750=0.03%, 1000=2.40%
  lat (msec)   : 2=27.67%, 4=20.33%, 10=2.13%, 100=35.27%, 250=12.06%
  lat (msec)   : 500=0.08%
  cpu          : usr=0.92%, sys=2.72%, ctx=20828, majf=0, minf=1085
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=99.9%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.1%
     issued rwts: total=403111,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=256

Run status group 0 (all jobs):
   READ: bw=78.4MiB/s (82.2MB/s), 78.4MiB/s-78.4MiB/s (82.2MB/s-82.2MB/s), io=1575MiB (1651MB), run=20093-20093msec

Disk stats (read/write):
  sdb: ios=398364/0, merge=2232/0, ticks=645937/0, in_queue=57832, util=11.36%
/mnt/hostpath # 
```

## Other paths

Testing underneath e.g., `/home` folder:

```bash
/home # fio --directory=perf-test --direct=1 --rw=randwrite --bs=4k --ioengine=libaio --iodepth=256 --runtime=20 --numjobs=4 --time_based --group_reporting --size=4m --name=iops-test-job --eta-newline=1
iops-test-job: (g=0): rw=randwrite, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=256
...
fio-3.27
Starting 4 processes
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
iops-test-job: Laying out IO file (1 file / 4MiB)
Jobs: 4 (f=4): [w(4)][14.3%][w=18.3MiB/s][w=4675 IOPS][eta 00m:18s]
Jobs: 4 (f=4): [w(4)][23.8%][w=22.6MiB/s][w=5773 IOPS][eta 00m:16s] 
Jobs: 4 (f=4): [w(4)][33.3%][w=22.9MiB/s][w=5863 IOPS][eta 00m:14s] 
Jobs: 4 (f=4): [w(4)][42.9%][w=19.7MiB/s][w=5032 IOPS][eta 00m:12s] 
Jobs: 4 (f=4): [w(4)][47.6%][w=18.9MiB/s][w=4846 IOPS][eta 00m:11s]
Jobs: 4 (f=4): [w(4)][60.0%][w=20.5MiB/s][w=5260 IOPS][eta 00m:08s] 
Jobs: 4 (f=4): [w(4)][65.0%][w=20.8MiB/s][w=5330 IOPS][eta 00m:07s]
Jobs: 4 (f=4): [w(4)][75.0%][w=23.4MiB/s][w=5998 IOPS][eta 00m:05s] 
Jobs: 4 (f=4): [w(4)][80.0%][w=20.7MiB/s][w=5300 IOPS][eta 00m:04s]
Jobs: 4 (f=4): [w(4)][90.0%][w=22.6MiB/s][w=5773 IOPS][eta 00m:02s] 
Jobs: 4 (f=4): [w(4)][95.0%][w=22.0MiB/s][w=5622 IOPS][eta 00m:01s]
Jobs: 4 (f=0): [f(4)][100.0%][w=26.1MiB/s][w=6680 IOPS][eta 00m:00s]
iops-test-job: (groupid=0, jobs=4): err= 0: pid=86: Wed Dec 15 12:54:09 2021
  write: IOPS=5236, BW=20.5MiB/s (21.5MB/s)(409MiB/20001msec); 0 zone resets
    slat (usec): min=39, max=99944, avg=760.50, stdev=6827.23
    clat (usec): min=12, max=481505, avg=194032.29, stdev=50504.97
     lat (usec): min=118, max=481772, avg=194793.10, stdev=50533.92
    clat percentiles (msec):
     |  1.00th=[  107],  5.00th=[  111], 10.00th=[  114], 20.00th=[  186],
     | 30.00th=[  192], 40.00th=[  194], 50.00th=[  199], 60.00th=[  201],
     | 70.00th=[  203], 80.00th=[  207], 90.00th=[  284], 95.00th=[  292],
     | 99.00th=[  305], 99.50th=[  384], 99.90th=[  401], 99.95th=[  405],
     | 99.99th=[  481]
   bw (  KiB/s): min=11432, max=26898, per=99.37%, avg=20815.97, stdev=864.50, samples=156
   iops        : min= 2858, max= 6724, avg=5203.72, stdev=216.13, samples=156
  lat (usec)   : 20=0.01%, 250=0.01%, 500=0.01%, 750=0.01%, 1000=0.01%
  lat (msec)   : 2=0.01%, 100=0.49%, 250=87.64%, 500=11.85%
  cpu          : usr=0.90%, sys=2.77%, ctx=104753, majf=0, minf=51
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=99.8%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.1%
     issued rwts: total=0,104742,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=256

Run status group 0 (all jobs):
  WRITE: bw=20.5MiB/s (21.5MB/s), 20.5MiB/s-20.5MiB/s (21.5MB/s-21.5MB/s), io=409MiB (429MB), run=20001-20001msec
```

```bash
/home # fio --directory=perf-test --direct=1 --rw=randread --bs=4k --ioengine=libaio --iodepth=256 --runtime=20 --numjobs=4 --time_based --group_reporting --size=4m --name=iops-test-job --eta-newline=1 --readonly
iops-test-job: (g=0): rw=randread, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=256
...
fio-3.27
Starting 4 processes
Jobs: 4 (f=4): [r(4)][15.0%][r=27.2MiB/s][r=6953 IOPS][eta 00m:17s]
Jobs: 4 (f=4): [r(4)][25.0%][r=26.7MiB/s][r=6825 IOPS][eta 00m:15s] 
Jobs: 4 (f=4): [r(4)][35.0%][r=23.3MiB/s][r=5961 IOPS][eta 00m:13s] 
Jobs: 4 (f=4): [r(4)][45.0%][r=31.8MiB/s][r=8144 IOPS][eta 00m:11s] 
Jobs: 4 (f=4): [r(4)][55.0%][r=29.7MiB/s][r=7612 IOPS][eta 00m:09s] 
Jobs: 4 (f=4): [r(4)][61.9%][r=23.4MiB/s][r=6000 IOPS][eta 00m:08s] 
Jobs: 4 (f=4): [r(4)][75.0%][r=21.8MiB/s][r=5577 IOPS][eta 00m:05s] 
Jobs: 4 (f=4): [r(4)][80.0%][r=22.5MiB/s][r=5769 IOPS][eta 00m:04s]
Jobs: 4 (f=4): [r(4)][90.0%][r=19.5MiB/s][r=4988 IOPS][eta 00m:02s] 
Jobs: 4 (f=4): [r(4)][100.0%][r=24.0MiB/s][r=6132 IOPS][eta 00m:00s]
iops-test-job: (groupid=0, jobs=4): err= 0: pid=94: Wed Dec 15 12:55:36 2021
  read: IOPS=6414, BW=25.1MiB/s (26.3MB/s)(501MiB/20002msec)
    slat (usec): min=83, max=91175, avg=621.02, stdev=5501.29
    clat (usec): min=10, max=373006, avg=158663.11, stdev=42290.33
     lat (usec): min=174, max=373407, avg=159284.42, stdev=42325.34
    clat percentiles (msec):
     |  1.00th=[  104],  5.00th=[  109], 10.00th=[  110], 20.00th=[  113],
     | 30.00th=[  116], 40.00th=[  124], 50.00th=[  180], 60.00th=[  186],
     | 70.00th=[  190], 80.00th=[  194], 90.00th=[  199], 95.00th=[  203],
     | 99.00th=[  284], 99.50th=[  288], 99.90th=[  296], 99.95th=[  300],
     | 99.99th=[  305]
   bw (  KiB/s): min=17792, max=32560, per=99.47%, avg=25522.13, stdev=895.84, samples=156
   iops        : min= 4448, max= 8140, avg=6380.26, stdev=223.95, samples=156
  lat (usec)   : 20=0.01%, 250=0.01%, 500=0.01%, 750=0.01%, 1000=0.01%
  lat (msec)   : 2=0.02%, 4=0.03%, 10=0.07%, 20=0.07%, 100=0.32%
  lat (msec)   : 250=97.59%, 500=1.89%
  cpu          : usr=0.89%, sys=2.79%, ctx=128326, majf=0, minf=1076
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=99.8%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.1%
     issued rwts: total=128305,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=256

Run status group 0 (all jobs):
   READ: bw=25.1MiB/s (26.3MB/s), 25.1MiB/s-25.1MiB/s (26.3MB/s-26.3MB/s), io=501MiB (526MB), run=20002-20002msec
```