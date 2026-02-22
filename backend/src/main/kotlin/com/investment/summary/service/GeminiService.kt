package com.investment.summary.service

import com.investment.summary.client.GeminiClient
import com.investment.summary.domain.entity.Category
import com.investment.summary.domain.entity.MarketSentiment
import com.investment.summary.dto.request.buildGeminiRequestWithGrounding
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import java.time.LocalDate

data class GeminiSummaryResult(
    val title: String,
    val content: String,
    val marketSentiment: MarketSentiment,
    val sourceUrls: List<String>
)

@Service
class GeminiService(
    private val geminiClient: GeminiClient
) {
    private val log = LoggerFactory.getLogger(javaClass)

    @Value("\${gemini.model}")
    private lateinit var model: String

    fun generateInvestmentSummary(category: Category, targetDate: LocalDate): GeminiSummaryResult {
        val prompt = buildPrompt(category, targetDate)
        log.info("[GeminiService] ${category.displayName} 요약 요청 시작 (날짜: $targetDate)")

        val response = geminiClient.generateContent(model, buildGeminiRequestWithGrounding(prompt))

        if (response.error != null) {
            throw RuntimeException("Gemini API 오류: ${response.error.message}")
        }

        val rawText = response.extractText()
        val sourceUrls = response.extractSourceUrls()

        log.info("[GeminiService] ${category.displayName} 요약 완료 (출처 ${sourceUrls.size}개)")
        return parseResponse(rawText, sourceUrls)
    }

    private fun buildPrompt(category: Category, targetDate: LocalDate): String = """
        당신은 전문 투자 분석가입니다.
        Google Search를 사용하여 ${targetDate} 기준으로 네이버 뉴스(news.naver.com)와 유튜브(youtube.com)에서
        "${category.displayName}" 관련 최신 투자 정보를 검색하고 분석해주세요.

        검색 키워드: ${category.searchQuery}

        반드시 아래 형식으로만 응답하세요 (다른 내용 추가 금지):

        TITLE: [30자 이내 한국어 제목]
        SENTIMENT: [POSITIVE 또는 NEUTRAL 또는 NEGATIVE 중 하나만]
        CONTENT:
        [마크다운 형식의 투자 정보 요약. 다음 항목 포함:
        ## 시장 개요
        (2~3문장으로 전반적 시황 설명)

        ## 주요 이슈
        - 이슈 1
        - 이슈 2
        - 이슈 3

        ## 핵심 투자 인사이트
        - 인사이트 1
        - 인사이트 2

        ## 내일 주목 포인트
        (다음날 주시할 사항 1~2가지)]

        주의: TITLE, SENTIMENT, CONTENT: 는 반드시 포함하고, 한국어로 작성하세요.
    """.trimIndent()

    private fun parseResponse(rawText: String, sourceUrls: List<String>): GeminiSummaryResult {
        val titleRegex = """TITLE:\s*(.+)""".toRegex()
        val sentimentRegex = """SENTIMENT:\s*(POSITIVE|NEUTRAL|NEGATIVE)""".toRegex()
        val contentRegex = """CONTENT:\s*\n([\s\S]+)""".toRegex()

        val title = titleRegex.find(rawText)?.groupValues?.getOrNull(1)?.trim()
            ?: "투자 정보 요약"

        val sentiment = sentimentRegex.find(rawText)?.groupValues?.getOrNull(1)?.let {
            runCatching { MarketSentiment.valueOf(it) }.getOrDefault(MarketSentiment.NEUTRAL)
        } ?: MarketSentiment.NEUTRAL

        val content = contentRegex.find(rawText)?.groupValues?.getOrNull(1)?.trim()
            ?: rawText.trim()

        return GeminiSummaryResult(
            title = title,
            content = content,
            marketSentiment = sentiment,
            sourceUrls = sourceUrls
        )
    }
}
