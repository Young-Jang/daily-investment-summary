package com.investment.summary.domain.repository

import com.investment.summary.domain.entity.Stock
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface StockRepository : JpaRepository<Stock, Long> {
    fun findByTickerIgnoreCase(ticker: String): Stock?
    fun findByIsActiveTrue(): List<Stock>
}
