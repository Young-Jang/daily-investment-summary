package com.investment.summary.exception

import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice
import java.time.LocalDateTime

data class ErrorResponse(
    val timestamp: LocalDateTime = LocalDateTime.now(),
    val status: Int,
    val message: String
)

@RestControllerAdvice
class GlobalExceptionHandler {
    private val log = LoggerFactory.getLogger(javaClass)

    @ExceptionHandler(IllegalArgumentException::class)
    fun handleBadRequest(e: IllegalArgumentException): ResponseEntity<ErrorResponse> {
        log.warn("잘못된 요청: ${e.message}")
        return ResponseEntity.badRequest().body(
            ErrorResponse(status = 400, message = e.message ?: "잘못된 요청입니다.")
        )
    }

    @ExceptionHandler(RuntimeException::class)
    fun handleInternalError(e: RuntimeException): ResponseEntity<ErrorResponse> {
        log.error("서버 오류: ${e.message}", e)
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
            ErrorResponse(status = 500, message = "서버 내부 오류가 발생했습니다.")
        )
    }
}
