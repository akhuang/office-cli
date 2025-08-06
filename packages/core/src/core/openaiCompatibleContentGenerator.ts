/**
 * Copyright 2025 Google LLC
 * SPDX-License-Identifier: Apache-2.0
 */

import {
  ContentGenerator,
  GenerateContentParameters,
  GenerateContentResponse,
  EmbedContentParameters,
  EmbedContentResponse,
  CountTokensParameters,
  CountTokensResponse,
} from './contentGenerator.js';

interface OpenAICompatibleConfig {
  baseUrl: string;
  apiKey: string;
  model: string;
}

export class OpenAICompatibleContentGenerator implements ContentGenerator {
  private config: OpenAICompatibleConfig;

  constructor(config: OpenAICompatibleConfig) {
    this.config = config;
  }

  async generateContent(
    request: GenerateContentParameters,
  ): Promise<GenerateContentResponse> {
    const response = await fetch(`${this.config.baseUrl}/v1/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.config.apiKey}`,
      },
      body: JSON.stringify({
        model: this.config.model,
        messages: this.convertToOpenAIMessages(request),
        stream: false,
      }),
    });

    if (!response.ok) {
      throw new Error(`OpenAI Compatible API error: ${response.statusText}`);
    }

    const data = await response.json();
    
    return {
      response: {
        text: () => data.choices[0]?.message?.content || '',
      },
    } as GenerateContentResponse;
  }

  async *generateContentStream(
    request: GenerateContentParameters,
  ): AsyncGenerator<GenerateContentResponse> {
    const response = await fetch(`${this.config.baseUrl}/v1/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.config.apiKey}`,
      },
      body: JSON.stringify({
        model: this.config.model,
        messages: this.convertToOpenAIMessages(request),
        stream: true,
      }),
    });

    if (!response.ok) {
      throw new Error(`OpenAI Compatible API error: ${response.statusText}`);
    }

    const reader = response.body?.getReader();
    if (!reader) {
      throw new Error('No response body');
    }

    const decoder = new TextDecoder();
    let buffer = '';

    try {
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split('\n');
        buffer = lines.pop() || '';

        for (const line of lines) {
          if (line.startsWith('data: ')) {
            const data = line.slice(6);
            if (data === '[DONE]') break;
            
            try {
              const parsed = JSON.parse(data);
              const content = parsed.choices[0]?.delta?.content;
              if (content) {
                yield {
                  response: {
                    text: () => content,
                  },
                } as GenerateContentResponse;
              }
            } catch (e) {
              // Skip invalid JSON lines
            }
          }
        }
      }
    } finally {
      reader.releaseLock();
    }
  }

  async embedContent(
    request: EmbedContentParameters,
  ): Promise<EmbedContentResponse> {
    const response = await fetch(`${this.config.baseUrl}/v1/embeddings`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.config.apiKey}`,
      },
      body: JSON.stringify({
        model: this.config.model,
        input: request.content.parts[0]?.text || '',
      }),
    });

    if (!response.ok) {
      throw new Error(`OpenAI Compatible API error: ${response.statusText}`);
    }

    const data = await response.json();
    
    return {
      embedding: {
        values: data.data[0]?.embedding || [],
      },
    };
  }

  async countTokens(
    request: CountTokensParameters,
  ): Promise<CountTokensResponse> {
    // Most OpenAI compatible APIs don't have token counting
    // We'll estimate based on text length (rough approximation: ~4 chars per token)
    const text = this.extractPrompt(request);
    const estimatedTokens = Math.ceil(text.length / 4);
    
    return {
      totalTokens: estimatedTokens,
    };
  }

  private convertToOpenAIMessages(request: GenerateContentParameters): Array<{role: string, content: string}> {
    if ('contents' in request && request.contents) {
      return request.contents.map((content: any) => ({
        role: 'user',
        content: content.parts.map((part: any) => part.text || '').join(''),
      }));
    }
    
    return [{ role: 'user', content: '' }];
  }

  private extractPrompt(request: GenerateContentParameters | CountTokensParameters): string {
    if ('contents' in request && request.contents) {
      return request.contents
        .map((content: any) => 
          content.parts
            .map((part: any) => part.text || '')
            .join('')
        )
        .join('\n');
    }
    
    if ('content' in request && request.content) {
      return request.content.parts
        .map((part: any) => part.text || '')
        .join('');
    }
    
    return '';
  }
}