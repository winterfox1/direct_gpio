#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

void init_gpio_out(int);
void set_gpio(int, int);

TickType_t delay_ticks = 1000 / portTICK_PERIOD_MS;

void app_main(void)
{
	init_gpio_out(4);

	while (1){
		set_gpio(1, 1);
		vTaskDelay(delay_ticks);
		set_gpio(1, 0);
		vTaskDelay(delay_ticks);
	}
}
