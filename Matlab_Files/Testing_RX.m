function Testing_RX()

    fig = figure('Name', 'Digital Communication Receiver', ...
                 'Position', [50, 50, 1400, 900], ...
                 'Color', [0.94 0.94 0.94]);

    % ===== TOP UI =====
    uicontrol('Style', 'text', 'Position', [500, 870, 400, 25], ...
              'String', ' RECEIVER', ...
              'FontSize', 15, 'FontWeight', 'bold', ...
              'BackgroundColor', [0.94 0.94 0.94]);

    uicontrol('Style', 'text', 'Position', [30, 815, 1340, 50], ...
              'BackgroundColor', [0.94 0.94 0.94]);

    uicontrol('Style', 'text', 'Position', [50, 837, 850, 22], ...
              'String', 'Waiting for transmission from Transmitter...', ...
              'FontSize', 14, 'FontWeight', 'bold', ...
              'BackgroundColor', [0.94 0.94 0.94], ...
              'HorizontalAlignment', 'left', ...
              'Tag', 'StatusText');

    uicontrol('Style', 'pushbutton', 'Position', [920, 825, 180, 35], ...
              'String', 'Check for Signal', 'FontSize', 11, 'FontWeight', 'bold', ...
              'BackgroundColor', [0.2 0.6 0.8], ...
              'ForegroundColor', 'white', ...
              'Callback', @(src, evt) checkAndReceive());

    uicontrol('Style', 'text', 'Position', [50, 818, 850, 18], ...
              'String', 'Parameters will be received from transmitter...', ...
              'FontSize', 10, ...
              'BackgroundColor', [0.94 0.94 0.94], ...
              'HorizontalAlignment', 'left', ...
              'Tag', 'ParamsText');

    % ===== AXES (NO GRAPH 5 TIME-DOMAIN LINE CODE) =====
    ax1 = axes('Parent', fig, 'Position', [0.06, 0.74, 0.88, 0.10]);
    title(ax1, '1) ASK Received (Passband)', 'FontSize', 10, 'FontWeight', 'bold');

    ax2 = axes('Parent', fig, 'Position', [0.06, 0.61, 0.88, 0.10]);
    title(ax2, '2) Coherent ASK Demodulation (Correlator Output)', 'FontSize', 10, 'FontWeight', 'bold');

    ax3 = axes('Parent', fig, 'Position', [0.06, 0.44, 0.42, 0.12]);
    title(ax3, '3) Symbol Decision Output (Recovered Line Symbols)', 'FontSize', 10, 'FontWeight', 'bold');

    ax4 = axes('Parent', fig, 'Position', [0.52, 0.44, 0.42, 0.12]);
    title(ax4, '4) Line Decoding Output (Recovered PCM Bits)', 'FontSize', 10, 'FontWeight', 'bold');

    ax6 = axes('Parent', fig, 'Position', [0.06, 0.24, 0.88, 0.15]);
    title(ax6, '5) Line-Coded Spectrum (Frequency Domain)', 'FontSize', 10, 'FontWeight', 'bold');

    ax7 = axes('Parent', fig, 'Position', [0.06, 0.04, 0.88, 0.15]);
    title(ax7, '6) Final Comparison (Original vs Reconstructed)', 'FontSize', 10, 'FontWeight', 'bold')
    function checkAndReceive()
        % ---- check TX variable exists ----
        if ~evalin('base', 'exist(''transmitted_data'', ''var'')')
            statusText = findobj('Tag', 'StatusText');
            set(statusText, 'String', 'ERROR: No signal found! Run Transmitter first and click "Generate".', ...
                'ForegroundColor', 'red');
            msgbox('Please run the Transmitter and click "Generate" first!', 'No Signal', 'warn');
            return;
        end

        tx_data = evalin('base', 'transmitted_data');
        params  = tx_data.params;

        statusText = findobj('Tag', 'StatusText');
        set(statusText, 'String', ['Receiving and processing signal with ' tx_data.line_coding '...'], ...
            'ForegroundColor', [0 0.5 0]);

        paramsText = findobj('Tag', 'ParamsText');
        set(paramsText, 'String', sprintf('RX Parameters: fm=%dHz | fc=%dHz | BitRate=%dbps | Levels=%d | Coding=%s', ...
            params.f_signal, params.fc, params.bit_rate, params.num_levels, tx_data.line_coding));

        % ---- extract signals/params ----
        ask_signal      = tx_data.ask_signal;
        t_carrier       = tx_data.t_carrier;

        original_signal = tx_data.original_signal;
        t_original      = tx_data.t_original;

        quantization_levels = tx_data.quantization_levels;

        % reference PCM bits (from TX) if available
        ref_bits = [];
        if isfield(tx_data, 'binary_data')
            ref_bits = tx_data.binary_data;
        end

        Tb = 1/params.bit_rate;
        fc = params.fc;

        technique = strtrim(char(tx_data.line_coding));
        tech = lower(technique);

        % Manchester / Diff Manchester / polar RZ change within bit -> need Tb/2 decisions
        halfBitNeeded = ismember(tech, {'polar rz','manchester','differential manchester'});
        Tsym = Tb;
        if halfBitNeeded
            Tsym = Tb/2;
        end

        num_bits_zoom = 25;
        zoom_duration = num_bits_zoom * Tb;
        zoom_idx = (t_carrier <= zoom_duration);

        plot(ax1, t_carrier(zoom_idx), ask_signal(zoom_idx), 'r', 'LineWidth', 1.2);
        xlabel(ax1, 'Time (s)'); ylabel(ax1, 'Amplitude (V)'); grid(ax1, 'on');

        hold(ax1, 'on');
        for i = 1:num_bits_zoom
            x_pos = (i-1)*Tb;
            line(ax1, [x_pos, x_pos], ylim(ax1), 'Color', [0.6 0.6 0.6], 'LineStyle', '--', 'LineWidth', 0.5);
        end
        hold(ax1, 'off');

        Ttotal = t_carrier(end);
        Nsym = floor(Ttotal / Tsym);

        sym_metric = zeros(1, Nsym);
        demod_wave = zeros(size(ask_signal));

        for k = 1:Nsym
            t0 = (k-1)*Tsym;
            t1 = k*Tsym;

            s_idx = find(t_carrier >= t0, 1, 'first');
            e_idx = find(t_carrier <  t1, 1, 'last');
            if isempty(s_idx) || isempty(e_idx) || e_idx <= s_idx
                continue;
            end

            t_seg = t_carrier(s_idx:e_idx);
            x_seg = ask_signal(s_idx:e_idx);

            c_seg = sin(2*pi*fc*t_seg);      % must match TX (sin)
            z = trapz(t_seg, x_seg .* c_seg);
            Ahat = (2/Tsym) * z;

            sym_metric(k) = Ahat;
            demod_wave(s_idx:e_idx) = Ahat;
        end

        plot(ax2, t_carrier(zoom_idx), demod_wave(zoom_idx), 'b', 'LineWidth', 1.4);
        xlabel(ax2, 'Time (s)'); ylabel(ax2, 'Correlator Output'); grid(ax2, 'on');

        hold(ax2, 'on');
        for i = 1:num_bits_zoom
            x_pos = (i-1)*Tb;
            line(ax2, [x_pos, x_pos], ylim(ax2), 'Color', [0.6 0.6 0.6], 'LineStyle', '--', 'LineWidth', 0.5);
        end
        hold(ax2, 'off');

        m = sym_metric;
        m(~isfinite(m)) = 0;

        abs_m = abs(m);
        hi = abs_m(abs_m > prctile(abs_m, 80));
        if isempty(hi)
            A = max(abs_m);
        else
            A = median(hi);
        end
        if A < 1e-9, A = 1; end

        m_norm = m / A;

        if strcmpi(technique, 'Unipolar')
            rx_symbols = double(m_norm > 0.5);   % 0 or 1
        else
            dead = 0.35;
            rx_symbols = zeros(size(m_norm));
            rx_symbols(m_norm >= (1-dead))  = +1;
            rx_symbols(m_norm <= -(1-dead)) = -1;
        end

        t_sym_edges = 0:Tsym:(length(rx_symbols)*Tsym);
        stairs(ax3, t_sym_edges, [rx_symbols, rx_symbols(end)], 'k', 'LineWidth', 1.5);
        xlabel(ax3, 'Time (s)'); ylabel(ax3, 'Symbol');
        grid(ax3, 'on');
        ylim(ax3, [min(-1.3,min(rx_symbols)-0.2) max(1.3,max(rx_symbols)+0.2)]);

        rx_bits = lineDecode(rx_symbols, technique, halfBitNeeded);

        t_bit_edges = 0:Tb:(length(rx_bits)*Tb);
        stairs(ax4, t_bit_edges, [rx_bits, rx_bits(end)], 'm', 'LineWidth', 1.5);
        xlabel(ax4, 'Time (s)'); ylabel(ax4, 'Bit');
        ylim(ax4, [-0.3, 1.3]); grid(ax4, 'on');

        % BER if reference bits exist
        if ~isempty(ref_bits)
            Lb = min(length(rx_bits), length(ref_bits));
            bit_errors = sum(rx_bits(1:Lb) ~= ref_bits(1:Lb));
            ber = bit_errors / max(1,Lb);
        else
            ber = NaN;
        end

        if halfBitNeeded
            samples_per_symbol = 100;  % 2 symbols/bit => 200 samples/bit
        else
            samples_per_symbol = 200;  % 1 symbol/bit => 200 samples/bit
        end

        line_wave = repelem(rx_symbols, samples_per_symbol);  % INTERNAL ONLY
        fs_line = samples_per_symbol / Tsym;                  % effective fs of line_wave

        x = line_wave(:);
        x = x - mean(x);                                      % remove DC

        N = length(x);
        Nfft = 2^nextpow2(max(N, 2048));
        X = fft(x, Nfft);

        f = (0:Nfft-1) * (fs_line/Nfft);
        mag = abs(X) / max(1,N);

        half = floor(Nfft/2) + 1;
        f1 = f(1:half);
        mag1 = mag(1:half);
        mag1 = mag1 / max(mag1 + eps);                        % normalize

        plot(ax6, f1, mag1, 'b', 'LineWidth', 1.2);
        xlabel(ax6, 'Frequency (Hz)'); ylabel(ax6, 'Magnitude (normalized)');
        grid(ax6, 'on');
        xlim(ax6, [0, fs_line/2]);

        bits_per_sample = log2(params.num_levels);
        num_samples_received = floor(length(rx_bits) / bits_per_sample);

        reconstructed_quantized = zeros(1, num_samples_received);
        qmin = min(quantization_levels);
        qmax = max(quantization_levels);

        for i = 1:num_samples_received
            bs = (i-1)*bits_per_sample + 1;
            be = i*bits_per_sample;
            sample_bits = rx_bits(bs:be);

            dec = bi2de(sample_bits, 'left-msb');
            reconstructed_quantized(i) = qmin + dec * (qmax - qmin) / (params.num_levels - 1);
        end

        t_reconstructed = linspace(0, params.duration, length(reconstructed_quantized));
        t_analog = 0:1/params.fs:params.duration;

        if isempty(reconstructed_quantized)
            reconstructed_analog = zeros(size(t_analog));
        else
            reconstructed_analog = interp1(t_reconstructed, reconstructed_quantized, t_analog, 'linear', 'extrap');
        end

        plot(ax7, t_original, original_signal, 'r--', 'LineWidth', 1.8);
        hold(ax7, 'on');
        plot(ax7, t_analog, reconstructed_analog, 'b', 'LineWidth', 1.4);
        hold(ax7, 'off');
        xlabel(ax7, 'Time (s)'); ylabel(ax7, 'Amplitude (V)');
        grid(ax7, 'on');
        legend(ax7, 'Original', 'Reconstructed', 'Location', 'best');

        % Update status
        if ~isnan(ber)
            set(statusText, 'String', sprintf('Signal processed successfully!  BER = %.6f', ber), ...
                'ForegroundColor', [0 0.5 0]);
        else
            set(statusText, 'String', 'Signal processed successfully! (BER not available)', ...
                'ForegroundColor', [0 0.5 0]);
        end
    end

    function out_bits = lineDecode(rx_symbols, technique, halfBitNeeded)
        technique = strtrim(char(technique));
        tech = lower(technique);

        switch tech
            case 'unipolar'
                out_bits = double(rx_symbols > 0);

            case 'polar rz'
                if ~halfBitNeeded
                    error('polar RZ requires Tb/2 symbol decisions.');
                end
                N = floor(length(rx_symbols)/2);
                out_bits = zeros(1, N);
                for k = 1:N
                    s1 = rx_symbols(2*k-1);
                    out_bits(k) = double(s1 == +1);
                end

            case 'polar nrz-l'
                out_bits = zeros(1, length(rx_symbols));
                out_bits(rx_symbols == -1) = 1;
                out_bits(rx_symbols == +1) = 0;

            case 'polar nrz-i'
                out_bits = zeros(1, length(rx_symbols));
                for k = 2:length(rx_symbols)
                    out_bits(k) = double(rx_symbols(k) ~= rx_symbols(k-1));
                end
                out_bits(1) = double(rx_symbols(1) == -1); % TX starts at +1

            case 'manchester'
                if ~halfBitNeeded
                    error('Manchester requires Tb/2 symbol decisions.');
                end
                N = floor(length(rx_symbols)/2);
                out_bits = zeros(1, N);
                for k = 1:N
                    s1 = rx_symbols(2*k-1);
                    s2 = rx_symbols(2*k);
                    if (s1==+1 && s2==-1)
                        out_bits(k) = 0;
                    elseif (s1==-1 && s2==+1)
                        out_bits(k) = 1;
                    else
                        out_bits(k) = double(s1 < 0);
                    end
                end

            case 'differential manchester'
                if ~halfBitNeeded
                    error('Differential Manchester requires Tb/2 symbol decisions.');
                end
                N = floor(length(rx_symbols)/2);
                out_bits = zeros(1, N);

                prev_end = rx_symbols(1);
                for k = 1:N
                    s1 = rx_symbols(2*k-1);
                    s2 = rx_symbols(2*k);
                    out_bits(k) = double(s1 == prev_end); % no start transition => 1
                    prev_end = s2;
                end

            case 'ami'
                out_bits = double(rx_symbols ~= 0);

            case 'b8zs'
                out_bits = double(rx_symbols ~= 0);
                i = 1;
                while i <= length(rx_symbols)-7
                    seg = rx_symbols(i:i+7);
                    if isequal(seg, [0 0 0  1 -1 0 -1  1]) || isequal(seg, [0 0 0 -1  1 0  1 -1])
                        out_bits(i:i+7) = 0;
                        i = i + 8;
                    else
                        i = i + 1;
                    end
                end

            case 'hdb3'
                out_bits = double(rx_symbols ~= 0);
                i = 1;
                while i <= length(rx_symbols)-3
                    seg = rx_symbols(i:i+3);
                    if seg(1)==0 && seg(2)==0 && seg(3)==0 && seg(4)~=0
                        out_bits(i:i+3) = 0;
                        i = i + 4;
                    else
                        i = i + 1;
                    end
                end

            otherwise
                out_bits = double(rx_symbols ~= 0);
        end
    end
end
