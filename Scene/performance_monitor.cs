/*
* performance_monitor.cs
* 
* This class samples average, minimum, and maximum frame rate (FPS), draw time (ms), and memory usage (MB)
* for any Godot project. Performance data is sampled every 10 frames (see `sample_rate`) and averages are
* calculated every 500 frames (see `print_rate`). The latest performance data and number of elapsed frames are
* displayed in a GUI overlay of the Godot project.
*
* This class can be added without dependencies to any Godot project
*
* Code References:
* 	Example GUI display: https://github.com/njromano/GodotFPSCSharp/blob/main/menus/DebugDisplay.cs
*
* Copyright Kaiya Magnuson 2024
*/

using Godot;
using System;
using System.IO;

public partial class performance_monitor : Node
{
	public int sample_rate = 10;			// Number of frames to wait between each profiler sample
	public int print_rate = 500;			// Number of frames to wait between calculating and printing averages

	// -----------------------------------------------------------------------------------------------------------------
	private double avg_FPS, min_FPS, max_FPS;
	private double fps;						// FPS at current frame
	private double fps_sum;					// Accumulator for FPS average

	private double avg_time, min_time, max_time;
	private double time;					// Draw time for current frame
	private double time_sum;				// Accumulator for time average

	private double avg_mem;
	private double mem;						// Memory usage at current frame
	private double mem_sum;					// Accumulator for memory usage average

	private long frame_count;				// The number of elapsed frames, used for averaging
	private long sample_count;				// The number of elapsed samples, used for averaging

	// Initialize min/max values and accumulators when project is launched
	public override void _Ready()
	{	
		avg_FPS = 0;
		min_FPS = 1000;		// Minimum FPS is not expected to exit the range [0,1000]
		max_FPS = 0;
		fps_sum = 0;

		avg_time = 0;
		min_time = 10000;	// Minimum draw time is not expected to exit the range [0,10000]
		max_time = 0;
		time_sum = 0;

		avg_mem = 0;
		mem_sum = 0;

		frame_count = 0;
		sample_count = 0;
	}

	/**
	* Controls FPS and draw time sampling rate. This function is run once per frame
	*/
	public override void _Process(double delta)
	{
		//int sample_rate = 10;			// Number of frames between samples
		//int print_rate = 500;			// Number of frames between printing stats
		frame_count++;

		if (frame_count % sample_rate == 0) {
			sample_count++;
			sampleFPS();
			sampleDrawTime();
			sampleMem();

			GetNode<Label>("FPSLabel").Text = $"Frame count: {frame_count}";
		}

		if (frame_count >= print_rate) {
			printStats();
			frame_count = 0;
			sample_count = 0;
			fps_sum = 0;
			time_sum = 0;
			mem_sum = 0;
		}
	}

	/**
	* Calculates average FPS, min FPS, and max FPS
	*/
	private void sampleFPS() {
		fps = Performance.GetMonitor(Performance.Monitor.TimeFps); 	// Gets current FPS from monitor
		fps_sum += fps;
		avg_FPS = fps_sum / sample_count;
		if (fps < min_FPS) {
			min_FPS = fps;
		}
		if (fps > max_FPS) {
			max_FPS = fps;
		}
	}

	/**
	* Calculates average draw time, min draw time, and max draw time in seconds
	*/
	private void sampleDrawTime() {
		time = Performance.GetMonitor(Performance.Monitor.TimeProcess);	// Get frame draw time from monitor
		time_sum += time;
		avg_time = time_sum / sample_count;
		if (time < min_time && time != 0) {		// Exclude t=0, since this is not physically possible
			min_time = time;
		}
		if (time > max_time) {
			max_time = time;
		}
	}

	/**
	* Calculates average memory usage in MiB
	*/
	private void sampleMem() {
		mem = Performance.GetMonitor(Performance.Monitor.MemoryStatic);	// Get frame draw time from monitor
		mem_sum += mem;
		avg_mem = mem_sum / sample_count;
	}

	/**
	* Prints formatted FPS, draw time, and memory usage stats
	*/
	private void printStats() {
		string label_str = "";												// Placeholder for formatted strings 
		label_str += $"\nAvg. FPS: {avg_FPS.ToString("F0")}"; 
		label_str += $"\nMin FPS: {min_FPS.ToString("F0")}";
		label_str += $"\nMax FPS: {max_FPS.ToString("F0")}";
		label_str += $"\nAvg. Draw Time: {toMS(avg_time).ToString("F2")} ms";
		label_str += $"\nMin Draw Time: {toMS(min_time).ToString("F2")} ms";
		label_str += $"\nMax Draw Time: {toMS(max_time).ToString("F2")} ms";
		label_str += $"\nAvg. Memory: {toMB(avg_mem).ToString("F2")} MB";
		label_str += $"\nCurrent Memory: {toMB(mem).ToString("F2")} MB";

		GetNode<Label>("Label").Text = label_str;						// This line from https://github.com/njromano/GodotFPSCSharp/blob/main/menus/DebugDisplay.cs
	}

	/**
	* Takes a time in seconds, returns time in milliseconds
	*/
	private double toMS(double sec) {
		return sec * 1000;
	}

	/**
	* Takes a size in bytes and returns the size in MB (megabytes)
	*/
	private double toMB(double bytes) {
		return bytes * 0.000001;
	}
}
