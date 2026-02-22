package com.investment.summary.service

import com.investment.summary.domain.entity.Category
import com.investment.summary.domain.entity.InvestmentSummary
import com.investment.summary.domain.repository.InvestmentSummaryRepository
import com.investment.summary.dto.response.SummaryResponse
import com.investment.summary.dto.response.toResponse
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDate
import java.time.LocalDateTime

@Service
@Transactional(readOnly = true)
class InvestmentSummaryService(
    private val summaryRepository: InvestmentSummaryRepository,
    private val geminiService: GeminiService
) {
    private val log = LoggerFactory.getLogger(javaClass)

    fun getSummariesByDate(date: LocalDate): List<SummaryResponse> =
        summaryRepository.findBySummaryDate(date).map { it.toResponse() }

    @Transactional
    fun generateAndSaveSummary(targetDate: LocalDate, category: Category): InvestmentSummary {
        val existing = summaryRepository.findBySummaryDateAndCategory(targetDate, category)

        return try {
            val result = geminiService.generateInvestmentSummary(category, targetDate)
            val sourceUrlText = result.sourceUrls.take(5).joinToString("\n")

            if (existing != null) {
                log.info("[SummaryService] 기존 요약 갱신: $targetDate / ${category.displayName}")
                existing.title = result.title
                existing.content = result.content
                existing.marketSentiment = result.marketSentiment
                existing.sourceUrl = sourceUrlText
                existing.updatedAt = LocalDateTime.now()
                summaryRepository.save(existing)
            } else {
                log.info("[SummaryService] 신규 요약 저장: $targetDate / ${category.displayName}")
                summaryRepository.save(
                    InvestmentSummary(
                        category = category,
                        summaryDate = targetDate,
                        title = result.title,
                        content = result.content,
                        marketSentiment = result.marketSentiment,
                        sourceUrl = sourceUrlText
                    )
                )
            }
        } catch (e: Exception) {
            log.error("[SummaryService] 요약 생성 실패: $targetDate / ${category.displayName} → ${e.message}", e)
            // 실패해도 FAILED 상태 레코드를 저장해 추적 가능하게 함
            existing ?: summaryRepository.save(
                InvestmentSummary(
                    category = category,
                    summaryDate = targetDate,
                    title = "[${category.displayName}] 요약 생성 실패",
                    content = "요약 생성 중 오류가 발생했습니다: ${e.message}"
                )
            )
        }
    }
}
