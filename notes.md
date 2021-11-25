# Notes

## NFS

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

## SMB

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
