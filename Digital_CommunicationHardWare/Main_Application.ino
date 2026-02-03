#include "driver/i2s.h"
#define BUTTON_PIN 5
#define I2S_BCLK_MIC 18
#define I2S_LRC_MIC 17
#define I2S_DIN_MIC 15
#define I2S_BCLK_SPK 21
#define I2S_LRC_SPK 23
#define I2S_DOUT_SPK 16
#define I2S_SD_SPK 22
const int SAMPLE_RATE = 16000;
const int BITS_PER_SAMPLE = 16;
const int BUFFER_SIZE = 2048; 
int16_t audio_buffer[BUFFER_SIZE];
void setup() {
  Serial.begin(115200);
  
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(I2S_SD_SPK, OUTPUT);
  digitalWrite(I2S_SD_SPK, LOW);
  
  Serial.println("Audio Passthrough Ready");
  Serial.println("Hold button to talk, release to stop");
 
  i2s_config_t i2s_rx_config = {
    .mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_RX),
    .sample_rate = SAMPLE_RATE,
    .bits_per_sample = (i2s_bits_per_sample_t)BITS_PER_SAMPLE,
    .channel_format = I2S_CHANNEL_FMT_ONLY_LEFT,
    .communication_format = I2S_COMM_FORMAT_STAND_I2S,
    .intr_alloc_flags = ESP_INTR_FLAG_LEVEL1,
    .dma_buf_count = 4,
    .dma_buf_len = 512
  };
  
  i2s_pin_config_t i2s_rx_pin_config = {
    .mck_io_num = I2S_PIN_NO_CHANGE,
    .bck_io_num = I2S_BCLK_MIC,
    .ws_io_num = I2S_LRC_MIC,
    .data_out_num = I2S_PIN_NO_CHANGE,
    .data_in_num = I2S_DIN_MIC
  };
  
  i2s_driver_install(I2S_NUM_0, &i2s_rx_config, 0, NULL);
  i2s_set_pin(I2S_NUM_0, &i2s_rx_pin_config);
  i2s_config_t i2s_tx_config = {
    .mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_TX),
    .sample_rate = SAMPLE_RATE,
    .bits_per_sample = (i2s_bits_per_sample_t)BITS_PER_SAMPLE,
    .channel_format = I2S_CHANNEL_FMT_ONLY_LEFT,
    .communication_format = I2S_COMM_FORMAT_STAND_I2S,
    .intr_alloc_flags = ESP_INTR_FLAG_LEVEL1,
    .dma_buf_count = 4,
    .dma_buf_len = 512
  };
  
  i2s_pin_config_t i2s_tx_pin_config = {
    .mck_io_num = I2S_PIN_NO_CHANGE,
    .bck_io_num = I2S_BCLK_SPK,
    .ws_io_num = I2S_LRC_SPK,
    .data_out_num = I2S_DOUT_SPK,
    .data_in_num = I2S_PIN_NO_CHANGE
  };
  
  i2s_driver_install(I2S_NUM_1, &i2s_tx_config, 0, NULL);
  i2s_set_pin(I2S_NUM_1, &i2s_tx_pin_config);
  
  Serial.println("Setup complete. Ready to use!");
}
void loop() {
  if (digitalRead(BUTTON_PIN) == LOW) {
    digitalWrite(I2S_SD_SPK, HIGH);
    
    static bool was_speaking = false;
    if (!was_speaking) {
      Serial.println("Passthrough active - speaking...");
      was_speaking = true;
    }
    
    size_t bytes_read;
    i2s_read(I2S_NUM_0, audio_buffer, sizeof(audio_buffer), &bytes_read, 10);
    
   
    if (bytes_read > 0) {
      size_t bytes_written;
      i2s_write(I2S_NUM_1, audio_buffer, bytes_read, &bytes_written, 10);
    }
  } else {
    
    static bool was_speaking = true;
    if (was_speaking) {
      digitalWrite(I2S_SD_SPK, LOW);
      Serial.println("Passthrough stopped");
      was_speaking = false;
    }
    delay(10);
  }
}
