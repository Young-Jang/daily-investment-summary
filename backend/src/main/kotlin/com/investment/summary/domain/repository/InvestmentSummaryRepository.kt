package com.investment.summary.domain.repository

import com.investment.summary.domain.entity.Category
import com.investment.summary.domain.entity.InvestmentSummary
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.time.LocalDate

@Repository
interface InvestmentSummaryRepository : JpaRepository<InvestmentSummary, Long> {
    fun findBySummaryDate(date: LocalDate): List<InvestmentSummary>
    fun findBySummaryDateAndCategory(date: LocalDate, category: Category): InvestmentSummary?
    fun findTop20ByOrderBySummaryDateDescCategoryAsc(): List<InvestmentSummary>
}
