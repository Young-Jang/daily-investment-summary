package com.investment.summary.controller

import com.investment.summary.dto.response.SummaryResponse
import com.investment.summary.service.InvestmentSummaryService
import org.springframework.format.annotation.DateTimeFormat
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import java.time.LocalDate

@RestController
@RequestMapping("/api/v1/summaries")
class InvestmentSummaryController(
    private val summaryService: InvestmentSummaryService
) {

    /**
     * GET /api/v1/summaries?date=yyyy-MM-dd
     * Flutter에서 호출하는 날짜별 투자 요약 목록 조회
     * date 미입력 시 오늘 날짜 기준 반환
     */
    @GetMapping
    fun getSummaries(
        @RequestParam(required = false)
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
        date: LocalDate?
    ): ResponseEntity<List<SummaryResponse>> {
        val targetDate = date ?: LocalDate.now()
        return ResponseEntity.ok(summaryService.getSummariesByDate(targetDate))
    }
}
