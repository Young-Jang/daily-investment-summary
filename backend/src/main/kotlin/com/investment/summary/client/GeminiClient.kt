package com.investment.summary.client

import com.investment.summary.config.OpenFeignConfig
import com.investment.summary.dto.request.GeminiRequest
import com.investment.summary.dto.response.GeminiResponse
import org.springframework.cloud.openfeign.FeignClient
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody

@FeignClient(
    name = "gemini-client",
    url = "\${gemini.api-url}",
    configuration = [OpenFeignConfig::class]
)
interface GeminiClient {

    @PostMapping("/v1beta/models/{model}:generateContent")
    fun generateContent(
        @PathVariable("model") model: String,
        @RequestBody request: GeminiRequest
    ): GeminiResponse
}
