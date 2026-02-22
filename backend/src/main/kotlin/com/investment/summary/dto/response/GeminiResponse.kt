package com.investment.summary.dto.response

import com.fasterxml.jackson.annotation.JsonIgnoreProperties
import com.fasterxml.jackson.annotation.JsonProperty

@JsonIgnoreProperties(ignoreUnknown = true)
data class GeminiResponse(
    val candidates: List<GeminiCandidate>? = null,
    val error: GeminiError? = null
) {
    fun extractText(): String =
        candidates?.firstOrNull()?.content?.parts?.firstOrNull()?.text ?: ""

    fun extractSourceUrls(): List<String> =
        candidates?.firstOrNull()
            ?.groundingMetadata?.groundingChunks
            ?.mapNotNull { it.web?.uri }
            ?: emptyList()
}

@JsonIgnoreProperties(ignoreUnknown = true)
data class GeminiCandidate(
    val content: GeminiCandidateContent? = null,
    val groundingMetadata: GroundingMetadata? = null
)

@JsonIgnoreProperties(ignoreUnknown = true)
data class GeminiCandidateContent(
    val parts: List<GeminiCandidatePart>? = null
)

@JsonIgnoreProperties(ignoreUnknown = true)
data class GeminiCandidatePart(
    val text: String? = null
)

@JsonIgnoreProperties(ignoreUnknown = true)
data class GroundingMetadata(
    val groundingChunks: List<GroundingChunk>? = null,
    val webSearchQueries: List<String>? = null
)

@JsonIgnoreProperties(ignoreUnknown = true)
data class GroundingChunk(
    val web: WebChunk? = null
)

@JsonIgnoreProperties(ignoreUnknown = true)
data class WebChunk(
    val uri: String? = null,
    val title: String? = null
)

@JsonIgnoreProperties(ignoreUnknown = true)
data class GeminiError(
    val code: Int? = null,
    val message: String? = null
)
