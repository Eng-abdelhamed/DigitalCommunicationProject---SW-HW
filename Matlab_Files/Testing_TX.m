function Testing_TX()
    % Create main figure
    fig = figure('Name', 'Digital Communication Transmitter', ...
                 'Position', [50, 50, 1400, 900], ...
                 'Color', [0.94 0.94 0.94]);

    % Default Parameters
    params.fs = 1000;           % Sampling frequency
    params.duration = 0.05;     % Signal duration (50ms)
    params.f_signal = 50;       % Input sine wave frequency (fm)
    params.amplitude = 4;       % Sine wave amplitude
    params.num_levels = 16;     % Quantization levels (4-bit)
    params.fc = 500;            % Carrier frequency for ASK
    params.bit_rate = 100;      % Bit rate for line coding


    uicontrol('Style', 'text', 'Position', [500, 870, 400, 25], ...
              'String', ' TRANSMITTER', ...
              'FontSize', 13, 'FontWeight', 'bold', ...
              'BackgroundColor', [0.94 0.94 0.94]);

    uicontrol('Style', 'text', 'Position', [30, 815, 1340, 50], ...
              'BackgroundColor', [0.85 0.9 0.95]);

    uicontrol('Style', 'text', 'Position', [50, 845, 110, 18], ...
              'String', 'Signal Freq (Hz):', ...
              'BackgroundColor', [0.85 0.9 0.95], 'HorizontalAlignment', 'left', ...
              'FontSize', 9);
    signalFreqEdit = uicontrol('Style', 'edit', 'Position', [50, 822, 80, 23], ...
              'String', num2str(params.f_signal), 'FontSize', 9);

    uicontrol('Style', 'text', 'Position', [160, 845, 120, 18], ...
              'String', 'Carrier Freq (Hz):', ...
              'BackgroundColor', [0.85 0.9 0.95], 'HorizontalAlignment', 'left', ...
              'FontSize', 9);
    carrierFreqEdit = uicontrol('Style', 'edit', 'Position', [160, 822, 80, 23], ...
              'String', num2str(params.fc), 'FontSize', 9);

    uicontrol('Style', 'text', 'Position', [270, 845, 100, 18], ...
              'String', 'Bit Rate (bps):', ...
              'BackgroundColor', [0.85 0.9 0.95], 'HorizontalAlignment', 'left', ...
              'FontSize', 9);
    bitRateEdit = uicontrol('Style', 'edit', 'Position', [270, 822, 80, 23], ...
              'String', num2str(params.bit_rate), 'FontSize', 9);

    uicontrol('Style', 'text', 'Position', [380, 845, 100, 18], ...
              'String', 'Quant. Levels:', ...
              'BackgroundColor', [0.85 0.9 0.95], 'HorizontalAlignment', 'left', ...
              'FontSize', 9);
    quantLevelsEdit = uicontrol('Style', 'edit', 'Position', [380, 822, 80, 23], ...
              'String', num2str(params.num_levels), 'FontSize', 9);

    uicontrol('Style', 'text', 'Position', [500, 845, 150, 18], ...
              'String', 'Line Coding Technique:', ...
              'FontSize', 9, 'FontWeight', 'bold', ...
              'BackgroundColor', [0.85 0.9 0.95], 'HorizontalAlignment', 'left');

    lineCodingMenu = uicontrol('Style', 'popupmenu', ...
              'Position', [500, 822, 180, 23], ...
              'String', {'Unipolar', 'polar RZ', 'Polar NRZ-L', 'Polar NRZ-I', ...
                         'Manchester', 'Differential Manchester', 'AMI', 'B8ZS', 'HDB3'}, ...
              'FontSize', 9);

    uicontrol('Style', 'pushbutton', 'Position', [710, 822, 120, 35], ...
              'String', 'Generate', 'FontSize', 11, 'FontWeight', 'bold', ...
              'BackgroundColor', [0.2 0.7 0.2], 'ForegroundColor', 'white', ...
              'Callback', @(src, evt) generateSignal());

    uicontrol('Style', 'text', 'Position', [860, 822, 480, 35], ...
              'String', 'Ready to transmit...', ...
              'FontSize', 9, 'FontWeight', 'bold', ...
              'ForegroundColor', [0 0.5 0], ...
              'BackgroundColor', [0.85 0.9 0.95], ...
              'Tag', 'TransmitStatus');

    
    ax1 = axes('Parent', fig, 'Position', [0.08, 0.73, 0.40, 0.12]);
    title('1. Original Sine Signal', 'FontSize', 10, 'FontWeight', 'bold');

    ax2 = axes('Parent', fig, 'Position', [0.55, 0.73, 0.40, 0.12]);
    title('2. Sampled Signal Spectrum (Frequency Domain)', 'FontSize', 10, 'FontWeight', 'bold');

    ax3 = axes('Parent', fig, 'Position', [0.08, 0.56, 0.40, 0.12]);
    title('3. Quantized Signal', 'FontSize', 10, 'FontWeight', 'bold');

    ax4 = axes('Parent', fig, 'Position', [0.55, 0.56, 0.40, 0.12]);
    title('4. Data Bits', 'FontSize', 10, 'FontWeight', 'bold');

   
    ax5 = axes('Parent', fig, 'Position', [0.08, 0.37, 0.87, 0.12]);
    title('5. Line Coded Signal (Time Domain)', 'FontSize', 10, 'FontWeight', 'bold');

    
    ax5b = axes('Parent', fig, 'Position', [0.08, 0.23, 0.87, 0.12]);
    title('5b. Line Coded Signal Spectrum (Frequency Domain)', 'FontSize', 10, 'FontWeight', 'bold');

    ax6 = axes('Parent', fig, 'Position', [0.08, 0.07, 0.87, 0.12]);
    title('6. ASK Modulated Signal (Time Domain)', 'FontSize', 10, 'FontWeight', 'bold');

    function generateSignal()
       
        params.f_signal = str2double(get(signalFreqEdit, 'String'));
        params.fc = str2double(get(carrierFreqEdit, 'String'));
        params.bit_rate = str2double(get(bitRateEdit, 'String'));
        params.num_levels = str2double(get(quantLevelsEdit, 'String'));

        % Validate
        if isnan(params.f_signal) || params.f_signal <= 0, errordlg('Invalid signal frequency!', 'Parameter Error'); return; end
        if isnan(params.fc) || params.fc <= 0, errordlg('Invalid carrier frequency!', 'Parameter Error'); return; end
        if isnan(params.bit_rate) || params.bit_rate <= 0, errordlg('Invalid bit rate!', 'Parameter Error'); return; end
        if isnan(params.num_levels) || params.num_levels < 2 || mod(log2(params.num_levels), 1) ~= 0
            errordlg('Quantization levels must be a power of 2 (e.g., 4, 8, 16, 32)!', 'Parameter Error'); return;
        end

        techniques = {'Unipolar', 'polar RZ', 'Polar NRZ-L', 'Polar NRZ-I', ...
                      'Manchester', 'Differential Manchester', 'AMI', 'B8ZS', 'HDB3'};
        selectedIdx = get(lineCodingMenu, 'Value');
        selectedTechnique = techniques{selectedIdx};

       
        t = 0:1/params.fs:params.duration;
        original_signal = params.amplitude * sin(2*pi*params.f_signal*t);

        cla(ax1);
        plot(ax1, t, original_signal, 'b', 'LineWidth', 1.5);
        xlabel(ax1, 'Time (s)'); ylabel(ax1, 'Amplitude (V)');
        title(ax1, sprintf('1. Original Sine Signal (f_m=%dHz)', params.f_signal), 'FontSize', 10, 'FontWeight', 'bold');
        grid(ax1, 'on');

       
        fm = params.f_signal;
        fs_sampling = 2 * fm;
        max_freq_display = 6 * fs_sampling;

        n_range = -10:10;
        freq_components_pos = fm + n_range * fs_sampling;
        freq_components_neg = -fm + n_range * fs_sampling;
        all_freq_components = unique([freq_components_pos, freq_components_neg]);
        valid_freqs = all_freq_components(abs(all_freq_components) <= max_freq_display);
        valid_freqs = sort(valid_freqs);

        impulse_amplitudes = ones(size(valid_freqs)) * params.amplitude * fs_sampling / 2;
        impulse_amplitudes_normalized = impulse_amplitudes / max(impulse_amplitudes);

        cla(ax2);
        stem(ax2, valid_freqs, impulse_amplitudes_normalized, 'r', 'LineWidth', 2, ...
             'MarkerSize', 7, 'MarkerFaceColor', 'r');
        xlabel(ax2, 'Frequency (Hz)'); ylabel(ax2, 'Magnitude (norm)');
        title(ax2, sprintf('2. Ideal Sampled Spectrum | f_s=2f_m=%dHz', fs_sampling), 'FontSize', 9, 'FontWeight', 'bold');
        xlim(ax2, [-max_freq_display, max_freq_display]);
        ylim(ax2, [0 1.3]);
        grid(ax2, 'on');

       
        num_samples = 16;
        t_sampled = linspace(0, params.duration, num_samples);
        sampled_signal = params.amplitude * sin(2*pi*params.f_signal*t_sampled);

       
        V_max = params.amplitude;
        L = params.num_levels;
        delta = (2 * V_max) / L;
        quantization_levels = -V_max + delta/2 + (0:L-1) * delta;
        decision_boundaries = -V_max + (0:L) * delta;

        quantized_signal = zeros(size(sampled_signal));
        quantized_indices = zeros(size(sampled_signal));
        for i = 1:length(sampled_signal)
            x = sampled_signal(i);
            interval_idx = floor((x + V_max) / delta);
            interval_idx = max(0, min(L - 1, interval_idx));
            quantized_signal(i) = quantization_levels(interval_idx + 1);
            quantized_indices(i) = interval_idx;
        end

        cla(ax3);
        hold(ax3, 'on');
        stem(ax3, t_sampled, sampled_signal, 'b', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'b');
        stairs(ax3, [t_sampled, t_sampled(end)+0.001], [quantized_signal, quantized_signal(end)], ...
               'Color', [0.8 0.2 0.8], 'LineWidth', 2.5);
        stem(ax3, t_sampled, quantized_signal, 'r', 'LineWidth', 1.5, 'MarkerSize', 7, 'MarkerFaceColor', 'r');
        hold(ax3, 'off');
        xlabel(ax3, 'Time (s)'); ylabel(ax3, 'Amplitude (V)');
        title(ax3, '3. Quantized Signal (Midrise)', 'FontSize', 10, 'FontWeight', 'bold');
        grid(ax3, 'on');

       
        bits_per_sample = log2(params.num_levels);
        binary_data = [];
        for i = 1:length(quantized_indices)
            binary_rep = de2bi(quantized_indices(i), bits_per_sample, 'left-msb');
            binary_data = [binary_data, binary_rep];
        end

        bit_duration = 1/params.bit_rate;
        t_binary_edges = 0:bit_duration:length(binary_data)*bit_duration;
        binary_stairs = [binary_data, binary_data(end)];

        cla(ax4);
        stairs(ax4, t_binary_edges, binary_stairs, 'k', 'LineWidth', 1.5);
        xlabel(ax4, 'Time (s)'); ylabel(ax4, 'Bit Value');
        ylim(ax4, [-0.3, 1.35]); grid(ax4, 'on');
        title(ax4, '4. Data Bits (with Bit Labels)', 'FontSize', 10, 'FontWeight', 'bold');

       
        hold(ax4, 'on');
        bit_centers = (0:length(binary_data)-1)*bit_duration + bit_duration/2;
        y_text_bits = 1.15;
        Nshow = min(40, length(binary_data));   % show first 40 bits to avoid clutter
        for k = 1:Nshow
            text(ax4, bit_centers(k), y_text_bits, num2str(binary_data(k)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8, 'Color', 'k');
        end
        hold(ax4, 'off');

        
        [line_coded, t_line] = applyLineCoding(binary_data, selectedTechnique, params.bit_rate);

        cla(ax5);
        plot(ax5, t_line, line_coded, 'm', 'LineWidth', 1.8);
        xlabel(ax5, 'Time (s)'); ylabel(ax5, 'Voltage (V)');
        title(ax5, ['5. Line Coded Signal (Time): ', selectedTechnique], 'FontSize', 10, 'FontWeight', 'bold');
        grid(ax5, 'on');
        ylim(ax5, [min(line_coded)-0.5, max(line_coded)+1.0]);

        
        hold(ax5, 'on');
        y_text_line = max(line_coded) + 0.25;
        Nshow2 = min(64, length(binary_data));
        for k = 1:Nshow2
            text(ax5, bit_centers(k), y_text_line, num2str(binary_data(k)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8, 'Color', 'k');
        end
        hold(ax5, 'off');

        samples_per_bit = 200;
        fs_line = samples_per_bit * params.bit_rate;  % Hz

        x = line_coded(:);
        x = x - mean(x);  % remove DC

        N = length(x);
        Nfft = 2^nextpow2(max(N, 2048));
        X = fft(x, Nfft);

        f = (0:Nfft-1) * (fs_line/Nfft);
        mag = abs(X) / N;

        half = floor(Nfft/2) + 1;
        f1 = f(1:half);
        mag1 = mag(1:half);
        mag1 = mag1 / max(mag1 + eps);  % normalize

        cla(ax5b);
        plot(ax5b, f1, mag1, 'b', 'LineWidth', 1.2);
        xlabel(ax5b, 'Frequency (Hz)'); ylabel(ax5b, 'Magnitude (normalized)');
        title(ax5b, '5b. Line Coded Signal Spectrum (Single-Sided)', 'FontSize', 10, 'FontWeight', 'bold');
        grid(ax5b, 'on');
        xlim(ax5b, [0, fs_line/2]);

        
        fs_modulation = 10000;
        total_duration = t_line(end);
        t_carrier = 0:1/fs_modulation:total_duration;

        line_coded_upsampled = interp1(t_line, line_coded, t_carrier, 'previous', 'extrap');
        carrier = sin(2*pi*params.fc*t_carrier);
        ask_signal = line_coded_upsampled .* carrier;

        num_bits_zoom = min(25, length(binary_data));
        zoom_duration = num_bits_zoom * bit_duration;
        zoom_idx = t_carrier <= zoom_duration;

        cla(ax6);
        plot(ax6, t_carrier(zoom_idx), ask_signal(zoom_idx), 'r', 'LineWidth', 1.3);
        xlabel(ax6, 'Time (s)'); ylabel(ax6, 'Amplitude (V)');
        title(ax6, '6. ASK Modulated Signal (Time, Zoomed)', 'FontSize', 10, 'FontWeight', 'bold');
        grid(ax6, 'on');

       
        transmitted_data.ask_signal = ask_signal;
        transmitted_data.t_carrier = t_carrier;

        transmitted_data.binary_data = binary_data;        % PCM bits (reference)
        transmitted_data.line_coded = line_coded;          % reference line-coded waveform
        transmitted_data.t_line = t_line;                  % reference time for line-coded

        transmitted_data.original_signal = original_signal;
        transmitted_data.t_original = t;

        transmitted_data.quantized_signal = quantized_signal;
        transmitted_data.t_sampled = t_sampled;
        transmitted_data.quantization_levels = quantization_levels;
        transmitted_data.decision_boundaries = decision_boundaries;
        transmitted_data.delta = delta;
        transmitted_data.line_coding = selectedTechnique;
        transmitted_data.fs_sampling = fs_sampling;
        transmitted_data.quantization_type = 'Midrise';
        transmitted_data.params = params;
        transmitted_data.params.num_samples = num_samples;

        assignin('base', 'transmitted_data', transmitted_data);

        statusText = findobj('Tag', 'TransmitStatus');
        set(statusText, 'String', 'Transmitted! ');
    end

    function [coded_signal, t_out] = applyLineCoding(bits, technique, bit_rate)
        bit_duration = 1/bit_rate;
        samples_per_bit = 200;

        coded_signal = [];

        switch technique
            case 'Unipolar'
                for bit = bits
                    if bit == 1
                        coded_signal = [coded_signal, ones(1, samples_per_bit)];
                    else
                        coded_signal = [coded_signal, zeros(1, samples_per_bit)];
                    end
                end

            case 'polar RZ'
                for bit = bits
                    if bit == 1
                        pulse = [ones(1, samples_per_bit/2), zeros(1, samples_per_bit/2)];
                    else
                        pulse = [-ones(1, samples_per_bit/2), zeros(1, samples_per_bit/2)];
                    end
                    coded_signal = [coded_signal, pulse];
                end

            case 'Polar NRZ-L'
                for bit = bits
                    if bit == 1
                        coded_signal = [coded_signal, -ones(1, samples_per_bit)];
                    else
                        coded_signal = [coded_signal, ones(1, samples_per_bit)];
                    end
                end

            case 'Polar NRZ-I'
                current_level = 1;
                for bit = bits
                    if bit == 1
                        current_level = -current_level;
                    end
                    coded_signal = [coded_signal, current_level * ones(1, samples_per_bit)];
                end

            case 'Manchester'
                for bit = bits
                    if bit == 0
                        coded_signal = [coded_signal, ones(1, samples_per_bit/2), -ones(1, samples_per_bit/2)];
                    else
                        coded_signal = [coded_signal, -ones(1, samples_per_bit/2), ones(1, samples_per_bit/2)];
                    end
                end

            case 'Differential Manchester'
                current_level = 1;
                for bit = bits
                    if bit == 0
                        current_level = -current_level;
                    end
                    coded_signal = [coded_signal, current_level * ones(1, samples_per_bit/2), ...
                                   -current_level * ones(1, samples_per_bit/2)];
                    current_level = -current_level;
                end

            case 'AMI'
                last_one_polarity = 1;
                for bit = bits
                    if bit == 1
                        coded_signal = [coded_signal, last_one_polarity * ones(1, samples_per_bit)];
                        last_one_polarity = -last_one_polarity;
                    else
                        coded_signal = [coded_signal, zeros(1, samples_per_bit)];
                    end
                end

            case 'B8ZS'
                last_polarity = -1;
                i = 1;
                while i <= length(bits)
                    if i+7 <= length(bits) && all(bits(i:i+7) == 0)
                        if last_polarity == 1
                            pattern = [0, 0, 0, 1, -1, 0, -1, 1];
                        else
                            pattern = [0, 0, 0, -1, 1, 0, 1, -1];
                        end

                        for p = pattern
                            coded_signal = [coded_signal, p * ones(1, samples_per_bit)];
                        end

                        last_polarity = pattern(8);
                        i = i + 8;
                    else
                        if bits(i) == 1
                            last_polarity = -last_polarity;
                            coded_signal = [coded_signal, last_polarity * ones(1, samples_per_bit)];
                        else
                            coded_signal = [coded_signal, zeros(1, samples_per_bit)];
                        end
                        i = i + 1;
                    end
                end

            case 'HDB3'
                last_polarity = 1;
                pulses_since_substitution = 0;
                i = 1;
                while i <= length(bits)
                    if i+3 <= length(bits) && all(bits(i:i+3) == 0)
                        if mod(pulses_since_substitution, 2) == 1
                            coded_signal = [coded_signal, ...
                                          zeros(1, samples_per_bit), ...
                                          zeros(1, samples_per_bit), ...
                                          zeros(1, samples_per_bit), ...
                                          -last_polarity * ones(1, samples_per_bit)];
                        else
                            coded_signal = [coded_signal, ...
                                          last_polarity * ones(1, samples_per_bit), ...
                                          zeros(1, samples_per_bit), ...
                                          zeros(1, samples_per_bit), ...
                                          last_polarity * ones(1, samples_per_bit)];
                            last_polarity = -last_polarity;
                        end
                        pulses_since_substitution = 0;
                        i = i + 4;
                    else
                        if bits(i) == 1
                            coded_signal = [coded_signal, last_polarity * ones(1, samples_per_bit)];
                            last_polarity = -last_polarity;
                            pulses_since_substitution = pulses_since_substitution + 1;
                        else
                            coded_signal = [coded_signal, zeros(1, samples_per_bit)];
                        end
                        i = i + 1;
                    end
                end
        end

        t_out = linspace(0, length(bits)*bit_duration, length(coded_signal));
    end
end
