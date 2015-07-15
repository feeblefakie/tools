#include <iostream>
#include <stdlib.h>
#include <math.h>

double sim_write(int sectors, int length);
double sim_read(int sectors, int length);
double get_transfer_rate(int length, double tr1, double tr2, double tr3, double tr4);
double revise(int sectors, double latency);

int main(int argc, char *argv[])
{
  if (argc > 4 || argc < 3) {
    std::cerr << argv[0] << " location(sectors) read-length is_write" << std::endl;
    exit(1);
  }
  int sectors = atoi(argv[1]);
  int length = atoi(argv[2]);
  bool is_write = false;
  if (argc == 4) { is_write = true; }

  double latency;
  if (is_write) {
    latency = sim_write(sectors, length);
  } else {
    latency = sim_read(sectors, length);
  }
  latency = revise(sectors, latency);
  std::cout << "sectors: " << sectors << " length: " << length << " latency: " << latency << std::endl;
  return 0;
}

double
sim_write(int sectors, int length)
{
  double transfer_rate; 
  double transfer_time;
  double seek_rotational_time;

  // transfer time
  if (sectors <= 16384000) {
    transfer_rate = 63.1619924050633;
  } else if (sectors <= 46899200) {
    transfer_rate = 61.4208523489933;
  } else if (sectors <= 78233600) {
    transfer_rate = 59.4463045751634;
  } else if (sectors <= 109158400) {
    transfer_rate = 57.0635529801325;
  } else if (sectors <= 138444800) {
    transfer_rate = 54.6230496503496;
  } else if (sectors <= 161792000) {
    transfer_rate = 52.4524798245614;
  } else if (sectors <= 184524800) {
    transfer_rate = 50.5680603603604;
  } else if (sectors <= 202547200) {
    transfer_rate = 48.1113011363636;
  } else if (sectors <= 220364800) {
    transfer_rate = 45.6498735632184;
  } else if (sectors <= 236544000) {
    transfer_rate = 43.455653164557;
  } else if (sectors <= 264192000) {
    transfer_rate = 40.6291874074074;
  } else if (sectors <= 275865600) {
    transfer_rate = 37.2052087719298;
  } else {
    transfer_rate = 35.4712346153846;
  }
  transfer_time = (double) length / (transfer_rate * 1024 * 1024);
  std::cout << "transfer_time: " << transfer_time << std::endl;

  // seek time + rotational time
  seek_rotational_time = 0.000000000025987447549259544609 * sectors + 0.005822;

  std::cout << "seek_rotational_time: " << seek_rotational_time << std::endl;

  return transfer_time + seek_rotational_time;
}

double
get_transfer_rate(int length, double tr1, double tr2, double tr3, double tr4)
{
  double transfer_rate = tr1;
  if (length > 102400 && length <= 1048576) {
    double unit = (tr2 - tr1) / (1048576 - 10240);
    transfer_rate = unit * (length - 10240) + tr1;
  } else if (length > 1048576 && length <= 10485760) {
    double unit = (tr3 - tr2) / (10485760 - 1048576);
    transfer_rate = unit * (length - 1048576) + tr2;
  } else if (length > 10485760 && length <= 104857600) {
    double unit = (tr4 - tr3) / (104857600 - 10485760);
    transfer_rate = unit * (length - 10485760) + tr3;
  } else if (length > 104857600) {
    transfer_rate = tr4;
  }
  return transfer_rate;
}

double
sim_read(int sectors, int length)
{
  double transfer_rate; 
  double transfer_time;
  double seek_rotational_time;
  // transfer time
  if (sectors <= 16384000) {
    transfer_rate = get_transfer_rate(length, 56.8983973857195, 58.6992582479971, 63.5570357311236, 64.9920285827621);
  } else if (sectors <= 46899200) {
    transfer_rate = get_transfer_rate(length, 56.9139638154108, 56.9139638154108, 62.717618769562, 63.753918845727);
  } else if (sectors <= 78233600) {
    transfer_rate = get_transfer_rate(length, 55.4783500343694, 55.4783500343694, 61.2889443267275, 61.8353689751781);
  } else if (sectors <= 109158400) {
    transfer_rate = get_transfer_rate(length, 52.4443856575047, 52.9117936800693, 58.029174864013, 59.267597221517);
  } else if (sectors <= 138444800) {
    transfer_rate = get_transfer_rate(length, 42.145236958675, 51.3216036576455, 55.5566391878029, 56.4658153066754);
  } else if (sectors <= 161792000) {
    transfer_rate = get_transfer_rate(length, 36.6870253790722, 48.953340138533, 53.3743030783144, 54.1931327320621);
  } else if (sectors <= 184524800) {
    transfer_rate = get_transfer_rate(length, 35.9344678208577, 46.8105851240754, 51.4944289101687, 52.2086534732549);
  } else if (sectors <= 202547200) {
    transfer_rate = get_transfer_rate(length, 33.7266941528252, 44.5303272168153, 48.9544340851216, 49.620818013579);
  } else if (sectors <= 220364800) {
    transfer_rate = get_transfer_rate(length, 32.3146257687965, 41.9440700656564, 46.337128960479, 47.0602055758123);
  } else if (sectors <= 236544000) {
    transfer_rate = get_transfer_rate(length, 30.433381322442, 40.5604278115991, 44.2260658022792, 44.6608252196432);
  } else if (sectors <= 264192000) {
    transfer_rate = get_transfer_rate(length, 29.5465161743435, 37.6600704576233, 41.2768398497641, 41.7073750736438);
  } else if (sectors <= 275865600) {
    transfer_rate = get_transfer_rate(length, 27.7698622068857, 34.0837011240195, 37.6886235757193, 38.1539617589415);
  } else {
    transfer_rate = get_transfer_rate(length, 27.3255362184846, 32.7126576515794, 36.2279309475276, 36.6255010299502);
  }
  std::cout << "transfer_rate: " << transfer_rate << std::endl;
  transfer_time = (double) length / (transfer_rate * 1024 * 1024);
  std::cout << "transfer_time: " << transfer_time << std::endl;

  // seek time + rotational time
  seek_rotational_time = 0.000000000022219763048783930570 * sectors + 0.005725;
  std::cout << "seek_rotational_time: " << seek_rotational_time << std::endl;

  return transfer_time + seek_rotational_time;
}

double
revise(int sectors, double latency)
{
  if (sectors <= 16384000) {
    latency *= 1.15637;
  } else if (sectors <= 46899200) {
    latency *= 1.03415;
  } else if (sectors <= 78233600) {
    latency *= 1.04281;
  } else if (sectors <= 109158400) {
    latency *= 0.963492;
  } else if (sectors <= 138444800) {
    latency *= 0.956978;
  } else if (sectors <= 161792000) {
    latency *= 0.934018;
  } else if (sectors <= 184524800) {
    latency *= 0.923386;
  } else if (sectors <= 202547200) {
    latency *= 0.947017;
  } else if (sectors <= 220364800) {
    latency *= 0.927703;
  } else if (sectors <= 236544000) {
    latency *= 0.936305;
  } else if (sectors <= 264192000) {
    latency *= 0.947878;
  } else if (sectors <= 275865600) {
    latency *= 0.963229;
  } else {
    latency *= 0.939925;
  }
  return latency;
}


/*
void
old(int sectors, int length)
{
  // seek time
  double seek_time = 1.519 * pow(10, -11) * sectors + 3.348 * pow(10, -3);

  // rotational time
  double rotational_time = AVE_LATENCY;

  // transfer time    
  double trasfer_rate = 0.0f;
  if (sectors < 479232000 && sectors >= 0) {
    trasfer_rate = -3.426f * pow(10, -8) * sectors + 99.449;
  } else {
    trasfer_rate = -6.451f * pow(10, -8) * sectors + 113.943;
  }
  double transfer_time = length / (trasfer_rate * 1024 * 1024);

  double total = transfer_time + seek_time + rotational_time;
  std::cout << "sectors: " << sectors << " length " << length << " time " << total << std::endl;
}
*/
