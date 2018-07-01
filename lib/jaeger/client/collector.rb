# frozen_string_literal: true

require 'thread'

module Jaeger
  module Client
    class Collector
      def initialize
        @buffer = Buffer.new
      end

      def send_span(span, end_time)
        context = span.context
        start_ts, duration = build_timestamps(span, end_time)
        return if !context.sampled? && !context.debug?

        @buffer << Jaeger::Thrift::Span.new(
          'traceIdLow' => context.trace_id,
          'traceIdHigh' => 0,
          'spanId' => context.span_id,
          'parentSpanId' => context.parent_id,
          'operationName' => span.operation_name,
          'references' => [],
          'flags' => context.flags,
          'startTime' => start_ts,
          'duration' => duration,
          'tags' => span.tags,
          'logs' => span.logs
        )
      end

      def retrieve
        @buffer.retrieve
      end

      private

      def build_timestamps(span, end_time)
        start_ts = (span.start_time.to_f * 1_000_000).to_i
        end_ts = (end_time.to_f * 1_000_000).to_i
        duration = end_ts - start_ts
        [start_ts, duration]
      end

      class Buffer
        def initialize
          @buffer = []
          @mutex = Mutex.new
        end

        def <<(element)
          @mutex.synchronize do
            @buffer << element
            true
          end
        end

        def retrieve
          @mutex.synchronize do
            elements = @buffer.dup
            @buffer.clear
            elements
          end
        end
      end
    end
  end
end
