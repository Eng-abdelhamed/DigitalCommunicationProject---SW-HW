# Advanced Digital Communication Transmitter and Receiver System With visualizations 
 
## Project Overview
A comprehensive MATLAB-based digital communication system simulator that demonstrates the complete transmission chain from analog signal to modulated digital signal. This project provides an interactive GUI for visualizing and analyzing each stage of digital communication.

---

## Project Objectives
- Understand the fundamentals of digital communication systems
- Implement and compare various line coding techniques
- Explore different digital modulation schemes
- Analyze signal characteristics in time and frequency domains
- Simulate realistic channel conditions with noise

---


## Features

### 1. **Signal Processing Chain**
The system implements the complete digital communication transmitter chain:

```
Analog Signal → Sampling → Quantization → Encoding → Line Coding → Modulation
```

### 2. **Line Coding Techniques (9 Types)**
| Technique | Type | Description |
|-----------|------|-------------|
| **Unipolar NRZ** | Unipolar | 0V for bit 0, +V for bit 1 |
| **Unipolar RZ** | Unipolar | Return to zero in second half of bit 1 |
| **Polar NRZ-L** | Polar | -V for bit 0, +V for bit 1 |
| **Polar NRZ-I** | Polar | Invert on bit 1, no change on bit 0 |
| **Manchester** | Biphase | Transition in middle of each bit |
| **Differential Manchester** | Biphase | Transition at start for bit 0 |
| **AMI** | Bipolar | Alternate Mark Inversion |
| **B8ZS** | Bipolar | Bipolar with 8-Zero Substitution |
| **HDB3** | Bipolar | High Density Bipolar 3 |

### 3. **Digital Modulation Schemes**
- **ASK** (Amplitude Shift Keying) - Amplitude varies with data
- **FSK** (Frequency Shift Keying) - Frequency varies with data  
- **PSK** (Phase Shift Keying) - Phase varies with data

### 4. **Adjustable Parameters**
- **Quantization Levels**: 2-5 bits (4-32 levels)
- **Bit Rate**: 100-500 bps
- **Carrier Frequency**: 300-1000 Hz
- **Signal Frequency**: 20-100 Hz
- **SNR**: 5-30 dB
- **Noise**: Enable/Disable channel noise

### 5. **Advanced Analysis Tools**
- **Time Domain Plots**: 7 synchronized visualizations
- **Spectrum Analyzer**: FFT-based frequency analysis
- **Power Spectral Density**: Welch's method PSD estimation
- **Spectrogram**: Time-frequency representation
- **Eye Diagram**: Signal quality and timing analysis
- **Bit Labeling**: Clear visualization of binary data

---

## Getting Started

### Installation
1. Download the MATLAB file
2. Place it in your MATLAB working directory
3. Open MATLAB

### User Guide

### Main Interface

#### Control Panel (Top)
The control panel contains all adjustable parameters:

1. **Line Coding Technique** - Dropdown menu to select encoding method
2. **Modulation Type** - Choose ASK, FSK, or PSK
3. **Quantization Bits** - Slider to set number of bits (2-5)
4. **Bit Rate** - Slider to adjust transmission speed (100-500 bps)
5. **Carrier Frequency** - Slider for modulation carrier (300-1000 Hz)
6. **SNR** - Slider to set Signal-to-Noise Ratio (5-30 dB)
7. **Signal Frequency** - Slider for input sine wave (20-100 Hz)
8. **Add Noise** - Checkbox to enable/disable AWGN channel

#### Action Buttons
- **Generate** - Process and display all signals
- **Spectrum** - Open frequency analysis window
- **Export** - Save data to file (.mat or .csv)

### Visualization Windows

#### Main Window - 7 Plots:
1. **Original Sine Wave** - Continuous analog input signal
2. **Sampled Signal** - Discrete-time samples
3. **Quantized Signal** - Amplitude-quantized samples
4. **PCM Encoded Signal** - Binary representation
5. **Line Coded Signal** - Selected line coding output
6. **Modulated Signal (Zoomed)** - First few bits with labels
7. **Complete Modulated Signal** - Full transmission

#### Spectrum Analysis Window - 6 Plots:
1. **Original Signal Spectrum** - Input frequency content
2. **Line Coded Spectrum** - After encoding
3. **Modulated Signal Spectrum** - After modulation
4. **Power Spectral Density** - PSD estimation
5. **Spectrogram** - Time-frequency plot
6. **Eye Diagram** - Quality assessment

---

## Experimental Procedures

### Experiment 1: Line Coding Comparison
**Objective**: Compare different line coding techniques

**Steps**:
1. Set parameters: Bit Rate = 300 bps, Quantization = 3 bits
2. Select "Unipolar NRZ" and click Generate
3. Observe the line coded signal characteristics
4. Repeat for each line coding technique
5. Compare bandwidth efficiency and DC component

**Expected Results**:
- Unipolar has DC component
- Manchester has no DC but double bandwidth
- Bipolar schemes better for long-distance transmission

### Experiment 2: Modulation Analysis
**Objective**: Analyze different modulation schemes

**Steps**:
1. Select "Manchester" line coding
2. Set Carrier Freq = 500 Hz, Bit Rate = 300 bps
3. Select ASK modulation and Generate
4. Click "Spectrum" to view frequency content
5. Repeat for FSK and PSK
6. Compare bandwidth and complexity

**Expected Results**:
- ASK: Simple, susceptible to amplitude noise
- FSK: Better noise immunity, wider bandwidth
- PSK: Best noise performance, constant envelope

### Experiment 3: Noise Effect Study
**Objective**: Study impact of channel noise

**Steps**:
1. Set SNR = 20 dB, disable noise
2. Generate signal and observe
3. Enable "Add Noise" checkbox
4. Generate again and compare
5. Adjust SNR from 5 to 30 dB
6. Observe eye diagram changes

**Expected Results**:
- Lower SNR causes signal distortion
- Eye diagram opens with higher SNR
- Different modulations have different noise immunity

---

## Technical Specifications

### Signal Processing Details

#### Sampling
- **Method**: Uniform sampling
- **Samples**: 24 per signal duration
- **Theorem**: Satisfies Nyquist criterion (fs ≥ 2fm)

#### Quantization
- **Type**: Uniform quantization
- **Levels**: 2^n where n = 2,3,4,5 bits
- **Error**: ±(Δ/2) where Δ = step size

#### Encoding
- **Method**: PCM (Pulse Code Modulation)
- **Format**: Natural binary coding
- **Bit ordering**: MSB first (left-most)

#### Line Coding
- **Pulse Width**: Equal for all techniques
- **Samples per bit**: 100 (for smooth visualization)
- **Voltage Levels**: ±1V (bipolar), 0/+1V (unipolar)

#### Modulation
- **Sampling Rate**: 20 kHz (oversampling for carrier)
- **ASK**: On-Off Keying variant (20% minimum amplitude)
- **FSK**: Frequency deviation = 50% of carrier
- **PSK**: Binary Phase Shift (0° and 180°)

---

## Data Export Format

### MAT File (.mat)
Contains two structures:
```matlab
signals = struct with fields:
    original: [1×N double]      % Original sine wave
    sampled: [1×M double]        % Sampled values
    quantized: [1×M double]      % Quantized values
    binary: [1×K double]         % Binary bits
    line_coded: [1×L double]     % Line coded signal
    modulated: [1×P double]      % Modulated signal
    t: [1×N double]              % Time vector (original)
    t_sampled: [1×M double]      % Time vector (sampled)
    t_line: [1×L double]         % Time vector (line coded)
    t_carrier: [1×P double]      % Time vector (modulated)

params = struct with fields:
    fs, duration, f_signal, amplitude, num_levels, fc, bit_rate, snr, add_noise
```

## Educational Value

### Learning Outcomes
Students will be able to:
1.  Understand sampling theorem and quantization
2.  Differentiate between various line coding schemes
3.  Compare digital modulation techniques
4.  Analyze signals in time and frequency domains
5.  Evaluate effect of noise on communication systems
6.  Design and optimize digital communication systems

### Key Concepts Demonstrated
- **Analog-to-Digital Conversion**
- **PCM Encoding**
- **Baseband Transmission**
- **Digital Modulation**
- **Spectral Analysis**
- **Channel Noise Effects**

---

## Project Information

### Course
**Digital Communications / Communication Engineering**

### Components Covered
-  Analog-to-Digital Conversion
-  Source Encoding (PCM)
-  Line Coding (9 techniques)
-  Digital Modulation (ASK, FSK, PSK)
-  Spectral Analysis
-  Noise Analysis

### Evaluation Criteria
1. **Completeness**: All stages implemented ✓
2. **Accuracy**: Correct implementation of techniques ✓
3. **User Interface**: Interactive and clear ✓
4. **Analysis**: Frequency domain and quality metrics ✓
5. **Documentation**: Comprehensive README ✓

---
## License and Usage

### Academic Use
This project is designed for educational purposes. Students are encouraged to:
- Modify and extend the code
- Use it for learning and experimentation
- Include in academic portfolios


## Conclusion

This Digital Communication Transmitter System provides a comprehensive, interactive platform for understanding digital communication fundamentals. Through hands-on experimentation with various line coding techniques and modulation schemes, users gain practical insights into real-world communication systems.

---

*Last Updated: February 2026*  
*Version: 1.0*  
*MATLAB Compatibility: R2018b and later*