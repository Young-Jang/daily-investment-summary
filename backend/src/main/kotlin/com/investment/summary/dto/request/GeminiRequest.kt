package com.investment.summary.dto.request

import com.fasterxml.jackson.annotation.JsonProperty

data class GeminiRequest(
    val contents: List<GeminiContent>,
    val tools: List<GeminiTool>? = null
)

data class GeminiContent(
    val parts: List<GeminiPart>
)

data class GeminiPart(
    val text: String
)

// Gemini 2.0 Google Search Grounding 도구
data class GeminiTool(
    @JsonProperty("google_search")
    val googleSearch: Map<String, Any> = emptyMap()
)

fun buildGeminiRequestWithGrounding(prompt: String) = GeminiRequest(
    contents = listOf(GeminiContent(parts = listOf(GeminiPart(text = prompt)))),
    tools = listOf(GeminiTool())
)
