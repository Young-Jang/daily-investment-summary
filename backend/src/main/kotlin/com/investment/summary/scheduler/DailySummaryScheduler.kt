package com.investment.summary.scheduler

import com.investment.summary.domain.entity.Category
import com.investment.summary.service.InvestmentSummaryService
import org.slf4j.LoggerFactory
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Component
import java.time.LocalDate

@Component
class DailySummaryScheduler(
    private val summaryService: InvestmentSummaryService
) {
    private val log = LoggerFactory.getLogger(javaClass)

    /**
     * 매일 00:05 실행 (평일/주말 모두)
     * 전일(D-1) 기준 투자 정보 수집 → Gemini 요약 → DB 저장
     */
    @Scheduled(cron = "0 5 0 * * *", zone = "Asia/Seoul")
    fun generateDailyInvestmentSummary() {
        val targetDate = LocalDate.now().minusDays(1)
        log.info("===== 일일 투자 정보 요약 배치 시작 (대상일: $targetDate) =====")

        var successCount = 0
        var failCount = 0

        Category.entries.forEach { category ->
            runCatching {
                summaryService.generateAndSaveSummary(targetDate, category)
                successCount++
                log.info("[배치] ✅ ${category.displayName} 요약 완료")
            }.onFailure { e ->
                failCount++
                log.error("[배치] ❌ ${category.displayName} 요약 실패: ${e.message}")
            }
        }

        log.info("===== 일일 투자 정보 요약 배치 완료 (성공: $successCount, 실패: $failCount) =====")
    }
}
