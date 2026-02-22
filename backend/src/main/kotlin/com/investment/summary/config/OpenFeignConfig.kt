package com.investment.summary.config

import feign.Logger
import feign.RequestInterceptor
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class OpenFeignConfig {

    @Value("\${gemini.api-key}")
    private lateinit var apiKey: String

    @Bean
    fun feignLoggerLevel(): Logger.Level = Logger.Level.BASIC

    @Bean
    fun geminiApiKeyInterceptor(): RequestInterceptor = RequestInterceptor { template ->
        template.query("key", apiKey)
    }
}
